---
description: Learn how to serve models on a Lambda On-Demand Cloud NVIDIA GH200 instance using vLLM.
tags:
  - on-demand cloud
---

# Serving Llama 3.1 8B using vLLM on an NVIDIA GH200 instance

This tutorial outlines how to serve Llama 3.1 8B using vLLM on an
On-Demand Cloud (ODC) instance backed with the NVIDIA GH200 Grace Hopper
Superchip. Though the tutorial uses Llama 3.1 8B as its example model, you can
use these steps to run any appropriately sized model vLLM supports on your
GH200 instance.

## Setting up your environment

### Launch your GH200 instance

Begin by launching a GH200 instance:

1. In the Lambda Cloud console, navigate to the
    [SSH keys page](https://cloud.lambdalabs.com/ssh-keys){ target="_blank" .external },
    click **Add SSH Key**, and then add or generate a SSH key.
1. Navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){ target="_blank" .external }
    and click **Launch Instance**.
1. Follow the steps in the instance launch wizard.
    -  _Instance type:_ Select **1x GH200 (96 GB).**
    -  _Region:_ Select an available region.
    -  _Filesystem:_ Don't attach a filesystem.
    -  _SSH key:_ Use the key you created in step 1.
1. Click **Launch instance**.
1. Review the EULAs. If you agree to them, click **I agree to the above** to
    start launching your new instance. Instances can take up to five minutes to
    fully launch.

### Get access to Llama 3.1 8B

Next, obtain a Hugging Face access token and get approval to access the Llama
3.1 8B repository:

1. If you don't already have a Hugging Face account,
    [create one](https://huggingface.co/join){ target="_blank" .external }.
1. Navigate to the
    [Hugging Face Access Tokens page](https://huggingface.co/settings/tokens){ target="_blank" .external }
    and click **Create new token**.
1. Under **Access Type**, click **Read** to give your token read-only access.
1. Name your token and then click **Create token**. A modal dialog opens.
1. Click **Copy** to copy your access token, paste the token somewhere safe
    for future use, and then click **Done** to exit the dialog.
1. Navigate to the
    [Llama-3.1-8B-Instruct page](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct){ target="_blank" .external }
    and then review and accept the model's license agreement. After you accept
    the agreement, Hugging Face submits a request to access the repository for
    approval. Approval tends to be fast. You can see the status of the request
    in your Hugging Face account settings.

### Set up your Python virtual environment

Create a new Python virtual environment and install the required libraries:

1. In the Lambda Cloud console, navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){ target="_blank" .external },
    find the row for your instance, and then click **Launch** in the
    **Cloud IDE** column. JupyterHub opens in a new window.
1. In JupyterHub's **Launcher** tab, under **Other**, click **Terminal** to
    open a new terminal.
1. In your terminal, create a Python virtual environment:

    ```bash
    python -m venv vllm-env
    ```

1. Activate the virtual environment:

    ```bash
    source vllm-env/bin/activate
    ```

1. Make sure that `pip`, `setuptools`, and `wheel` are all up to date:

    ```bash
    python -m pip install -U pip &&
    python -m pip install -U setuptools wheel
    ```

1. Install the latest nightly build of `torch`:

    ```bash
    pip install torch --index-url https://download.pytorch.org/whl/cu124
    ```

### Install and configure vLLM

Now that you've set up your Python virtual environment, you can install and
configure vLLM. Begin by installing Triton, which vLLM depends on to run
on GH200 instances:

1. Clone the Triton GitHub repository:

    ```bash
    git clone https://github.com/triton-lang/triton.git
    ```

1. Navigate to the cloned repository, and then install Triton's dependencies:

    ```bash
    cd triton/python &&
    pip install ninja cmake wheel
    ```

1. Install Triton:

    ```bash
    pip install -e .
    ```

After Triton finishes installing, you can install and configure vLLM:

1. Return to your home directory, and then clone the vLLM GitHub repository:

    ```bash
    cd $HOME &&
    git clone https://github.com/vllm-project/vllm.git
    ```

1. Navigate to your cloned repository, and then configure your vLLM
    requirements files to use the version of `torch` you installed earlier:

    ```bash
    cd vllm &&
    python use_existing_torch.py
    ```

1. Install the rest of vLLM's dependencies, and then finish installing
    vLLM. This step can take several minutes to complete:

    ```bash
    pip install -r requirements-build.txt &&
    pip install -e . --no-build-isolation
    ```

## Serving a model with vLLM

### Start the vLLM API server

To start a vLLM API server that serves the Llama 3.1 8B model:

1. Open your `.bashrc` file for editing:

    ```bash
    nano ~/.bashrc
    ```

1. At the bottom of the file, set the following environment variables.
    Replace `<HF-TOKEN>` with your Hugging Face user access token:

    ```bash
    export HF_TOKEN=<HF-TOKEN>
    export HF_HOME="/home/ubuntu/.cache/huggingface"
    export MODEL_REPO=meta-llama/Meta-Llama-3.1-8B-Instruct
    ```

1. Save and exit.
1. Update your environment with your new environment variables:

    ```bash
    source ~/.bashrc
    ```

1. Start the vLLM API server. The server loads your model and then begins
    serving it:

    ```bash
    vllm serve meta-llama/Meta-Llama-3.1-70B-Instruct --dtype auto
    ```

### Test the vLLM API server

After the API server loads your model, verify that the server is working as
expected:

1. In your instance's JupyterHub, click **+** to create a new Launcher tab
    and then click **Terminal** to open a new terminal.
1. Send a prompt to the API server:

    ```bash
    curl -X POST http://localhost:8000/v1/completions \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"What is the name of the capital of France?\",
            \"model\": \"${MODEL_REPO}\",
            \"temperature\": 0.0,
            \"max_tokens\": 1
            }"
    ```

    You should see output similar to the following:

    ```json { .no-copy }
    {"id":"cmpl-d3a33498b5d74d9ea09a7c256733b8df","object":"text_completion","created":1722545598,"model":"meta-llama/Meta-Llama-3.1-8B-Instruct","choices":[{"index":0,"text":"Paris","logprobs":null,"finish_reason":"length","stop_reason":null}],"usage":{"prompt_tokens":11,"total_tokens":12,"completion_tokens":1}}
    ```

### Add a firewall rule

Optionally, you can add a firewall rule to allow external traffic to your API
server. For details, see
[Firewalls > Creating a firewall rule](../firewalls.md#creating-a-firewall-rule).
vLLM serves on port 8000 by default.

## Cleaning up

When you're done with your instances, terminate them to avoid incurring
unnecessary costs:

1. In the Lambda Cloud console, navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){ target="_blank" .external }.
1. Select the checkboxes of the instances you want to delete.
1. Click **Terminate**. A dialog appears.
1. Follow the instructions and then click **Terminate instances** to
    terminate your instances.

## Next steps

-  To learn how to benchmark your GH200 instance against other instances, see
    [Running a PyTorch®-based benchmark on an NVIDIA GH200 instance](running-benchmark-gh200.md).
-  For details on using vLLM to serve models on other instance types, see
    [Serving the Llama 3.1 8B and 70B models using Lambda Cloud on-demand instances](../../education/large-language-models/serving-llama-3-1-docker.md).
-  To learn how to use Hugging Face's Diffusers and Transformers libraries on
    a GH200 instance, see
    [Running Hugging Face Transformers and Diffusers on an NVIDIA GH200 instance](running-huggingface-diffusers-transformers-gh200.md).
-  For more tips and tutorials, see our [Education](../../education/index.md)
    section.
