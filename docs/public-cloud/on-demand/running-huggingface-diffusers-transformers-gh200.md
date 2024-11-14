---
description: Learn how to use Hugging Face libraries to generate images and chatbot-style responses on a Lambda On-Demand Cloud NVIDIA GH200 instance.
tags:
  - on-demand cloud
---

# Running Hugging Face Transformers and Diffusers on an NVIDIA GH200 instance

[Hugging Face](https://huggingface.co/){ target="_blank" .external } provides
several powerful Python libraries that provide easy access to a wide range of
pre-trained models. Among the most popular are
[Diffusers](https://huggingface.co/docs/diffusers/index){ target="_blank" .external },
which focuses on diffusion-based generative AI, and
[Transformers](https://huggingface.co/docs/transformers/en/index){ target="_blank" .external },
which supports common AI/ML tasks across several different modalities. This
tutorial demonstrates how to use these libraries to generate images and
chatbot-style responses on an On-Demand Cloud (ODC) instance backed with the
NVIDIA GH200 Grace Hopper Superchip.

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

### Set up your Python virtual environment

Next, create a new Python virtual environment and install the required
libraries:

1. In the Lambda Cloud console, navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){ target="_blank" .external },
    find the row for your instance, and then click **Launch** in the
    **Cloud IDE** column. JupyterHub opens in a new window.
1. In JupyterHub's **Launcher** tab, under **Other**, click **Terminal** to
    open a new terminal.
1. In your terminal, create a Python virtual environment:

    ```bash
    python -m venv --system-site-packages hf-tests
    ```

1. Activate the virtual environment:

    ```bash
    source hf-tests/bin/activate
    ```

1. Install the Hugging Face Transformers library, Diffusers library, and
    other dependencies:

    ```bash
    pip install transformers diffusers["torch"] tf-keras==2.17.0 accelerate
    ```

## Using Hugging Face Transformers and Diffusers

Now that you've set up your environment, you can create and run Python
programs based on Hugging Face Transformers and Diffusers. This section provides
a few example programs to get you started.

### Generate a chatbot response with the Transformers library

To generate a chatbot-style response with the Hugging Face Transformers library:

1. Open a new Python file named `test_transformers.py` for editing:

    ```bash
    nano test_transformers.py
    ```

1. Paste the following Hugging Face Transformers test script into the file:

    ```python
    import transformers
    import torch

    model_id = "facebook/opt-1.3b"

    pipeline = transformers.pipeline(
        "text-generation", model=model_id, model_kwargs={"torch_dtype": torch.bfloat16}, device_map="auto"
    )

    output = pipeline("How is ice cream made?")
    print(output)
    ```

1. Save and exit.
1. Run the script:

    ```bash
    python test_transformers.py
    ```

    You should get a result similar to the following:

    ```json { .no-copy }
    [{'generated_text': 'How is ice cream made?\n\nIce cream is made by mixing milk, sugar, and'}]
    ```

To learn more about how to use the Transformers library, see the
[Transformers section](https://huggingface.co/docs/transformers/index){ target="_blank" .external }
in the Hugging Face docs.

### Generate an image with the Diffusers library

To generate a prompt-based image with the Hugging Face Diffusers library:

1. Open a new Python file named `test_diffusers.py` for editing:

    ```bash
    nano test_diffusers.py
    ```

1. Paste the following Hugging Face Diffusers test script into the file.
    Feel free to change the prompt if desired:

    ```python
    from diffusers import DiffusionPipeline
    import torch

    pipeline = DiffusionPipeline.from_pretrained("stable-diffusion-v1-5/stable-diffusion-v1-5", torch_dtype=torch.float16)
    pipeline.to("cuda")
    image = pipeline("An image of an elephant in the style of Matisse").images[0]
    image.save("elephant_matisse.png")
    ```

1. Save and exit.
1. Run the script:

    ```bash
    python test_diffusers.py
    ```

    The resulting image file appears in JupyterHub's left nav. Double-click
    it to view the image:

    ![Generated image of an elephant in the style of Matisse](../../assets/images/elephant_matisse.png)

To learn more about how to use the Diffusers library, see the
[Diffusers section](https://huggingface.co/docs/diffusers/index){ target="_blank" .external }
in the Hugging Face docs.

## Cleaning up

When you're done with your instance, terminate it to avoid incurring unnecessary
costs:

1. In the Lambda Cloud console, navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){ target="_blank" .external }.
1. Select the checkboxes of the instances you want to delete.
1. Click **Terminate**. A dialog appears.
1. Follow the instructions and then click **Terminate instances** to
    terminate your instances.

## Next steps

-  To learn how to benchmark your GH200 instance against other instances, see
    [Running a PyTorch®-based benchmark on an NVIDIA GH200 instance](running-benchmark-gh200.md).
-  To explore more Hugging Face libraries, see
    [Libraries](https://huggingface.co/docs/hub/en/models-libraries){ target="_blank" .external }
    in the Hugging Face docs.
-  For more tips and tutorials, see our [Education](../../education/index.md)
    section.
