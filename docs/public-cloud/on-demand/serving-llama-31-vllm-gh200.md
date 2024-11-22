---
description: Learn how to serve models on a Lambda On-Demand Cloud NVIDIA GH200 instance using vLLM.
tags:
  - on-demand cloud
---

# Serving Llama 3.1 8B and 70B using vLLM on an NVIDIA GH200 instance

This tutorial outlines how to serve Llama 3.1 8B and 70B using vLLM on an
On-Demand Cloud (ODC) instance backed with the NVIDIA GH200 Grace Hopper
Superchip. These two models represent two different ways you might serve a
model on an NVIDIA GH200 instance:

- Llama 3.1 8B fits entirely in the GH200 GPU's VRAM. You can serve this model
    without additional configuration.
- Llama 3.1 70B exceeds the GH200 GPU's available memory. However, you can
    still serve this model on your GH200 instance by offloading the model
    weights to the onboard CPU's memory. This technique, known as *CPU
    offloading*, effectively expands the available GPU memory for storing model
    weights, but requires CPU-GPU data transfer during each forward pass. Due
    to its high-bandwidth chip-to-chip connection, the GH200 is uniquely
    suited for offloading tasks like this one.

Though the tutorial focuses on these two Llama models, you can use
these steps to serve any appropriately sized model vLLM supports on your
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

### Get access to Llama 3.1 8B and 70B

Next, obtain a Hugging Face access token and get approval to access the Llama
3.1 8B and Llama 3.1 70B repositories:

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
    [Llama-3.1-8B-Instruct page](https://huggingface.co/meta-llama/Llama-3.1-8B-Instruct){ target="_blank" .external },
    and then review and accept the model's license agreement. After you accept
    the agreement, Hugging Face submits a request to access the model's
    repository for approval. On approval, you should gain access to all
    versions of the model (8B, 70B, and 405B).

    The approval process tends to be fast. You can see the status of the
    request in your Hugging Face account settings.

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
    python -m pip install -U pip setuptools wheel
    ```

1. Install the latest nightly build of `torch`:

    ```bash
    pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cu124
    ```

1. Install a version of `fsspec` known to be compatible with the version of
    the Hugging Face `datasets` library used by recent nightly `torch`
    releases:

    ```bash
    pip install fsspec[http]==2024.9.0
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
    pip install ninja cmake
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
    vLLM. This step can take up to 15 minutes to complete:

    ```bash
    pip install -r requirements-build.txt &&
    pip install -e . --no-build-isolation
    ```

## Serving a model with vLLM

After vLLM finishes installing, you can start serving models on your vLLM
instance.

### Serve Llama 3.1 8B using the vLLM API server

To start a vLLM API server that serves the Llama 3.1 8B model:

1. Set the following environment variables. Replace `<HF-TOKEN>` with your
    Hugging Face user access token:

    ```bash
    export HF_TOKEN=<HF-TOKEN> ; \
    export HF_HOME="/home/ubuntu/.cache/huggingface" ; \
    export MODEL_REPO=meta-llama/Meta-Llama-3.1-8B-Instruct
    ```

1. Start a `tmux` session for your vLLM server.

    ```bash
    tmux new-session -s run-vllm
    ```

1. Start the vLLM API server. The server loads your model and then begins
    serving it:

    ```bash
    vllm serve ${MODEL_REPO} --dtype auto
    ```

    When the server is ready, you should see output similar to the following:

    ```text { .no-copy }
    INFO:     Started server process [12821]
    INFO:     Waiting for application startup.
    INFO:     Application startup complete.
    INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
    ```

    !!! note

        This step might take several minutes to complete.

### Test the vLLM API server { #test-the-vllm-api-server }

Now that your vLLM API server is up and running, verify that it's working as
expected:

1. Detach the `tmux` session for your server by pressing ++ctrl++ + ++b++,
    then ++d++.
1. Send a prompt to the server:

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

To return to the `tmux` session for your server:

1. Press ++ctrl++ + ++b++, then ++d++ to detach your current session.
1. Reattach your vLLM server session:

    ```bash
    tmux attach-session -t run-vllm
    ```

### Serve Llama 3.1 70B using CPU offloading

For models that exceed the GH200's VRAM, such as Llama 3.1 70B, you can use
CPU offloading to offload model weight storage to the onboard CPU. The
GH200 features a high-bandwidth connection between its CPU and GPU, which
can provide significant speed gains for tasks that require CPU offloading.

To serve Llama 3.1 70B using CPU offloading:

1. If needed, press ++ctrl++ + ++b++, then ++d++ to detach your current
    session.
1. Set the `MODEL_REPO` environment variable to Llama 3.1 70B instead of
    Llama 3.1 8B:

    ```bash
    export MODEL_REPO=meta-llama/Meta-Llama-3.1-70B-Instruct
    ```

1. Reattach your vLLM server session:

    ```bash
    tmux attach-session -t run-vllm
    ```

1. Press ++ctrl++ + ++c++ to stop the currently running server.
1. Start the server again, this time using the Llama 3.1 70B model and enabling
    CPU offloading by appending the `--cpu-offload-gb` flag.

    ```bash
    vllm serve ${MODEL_REPO} --dtype auto --cpu-offload-gb 90
    ```

    !!! note

        This step might take up to 20 minutes to complete.

1. After the model finishes loading and the server starts serving, detach your
    `tmux` session again.
1. Send a test prompt as described in the
    [Testing the vLLM API Server](#test-the-vllm-api-server) section above.

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
