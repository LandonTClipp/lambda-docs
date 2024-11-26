---
description: Learn how to fine-tune the Mochi video generation model on GH200.
tags:
  - generative ai
  - on-demand cloud
---

# Fine-tuning the Mochi video generation model on GH200

This guide helps you get started fine-tuning
[Genmo's Mochi video generation model](https://www.genmo.ai/){ target="_blank" .external }
using a
[Lambda On-Demand Cloud](https://lambdalabs.com/service/gpu-cloud){ target="_blank" .external }
GH200 instance.

## Launch your GH200 instance

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

## Install dependencies

- Install the dependencies needed for this guide by running:

    ```bash
    git clone https://github.com/genmoai/mochi.git
    cd mochi-tune
    pip install --upgrade pip setuptools wheel packaging
    pip install -e . --no-build-isolation
    pip install moviepy==1.0.3 pillow==9.5.0 av==13.1.0
    sudo apt -y install bc
    ```

## Download the model weights

- Download the model weights by running:

    ```bash
    python3 ./scripts/download_weights.py weights/
    ```

## Prepare your dataset

- Prepare your dataset by following the
[README for Genmo's Mochi 1 LoRA Fine-tuner](https://github.com/genmoai/mochi/blob/main/demos/fine_tuner/README.md){ target="_blank" .external }.

## Begin fine-tuning

- Begin fine-tuning by running:

    ```bash
    bash ./demos/fine_tuner/run.bash -c ./demos/fine_tuner/configs/lora.yaml -n 1
    ```

You should see output similar to:

```text { .no-copy }
Starting training with 1 GPU(s), mode: single_gpu
Using config: ./demos/fine_tuner/configs/lora.yaml
model=weights/dit.safetensors, optimizer=, start_step_num=0
Found 44 training videos in videos_prepared
Loaded 44/44 valid file pairs.
Loading model
Training type: LoRA
Attention mode: sdpa
Loading eval pipeline ...
Timing load_text_encoder
Timing load_vae
Stage                   Time(s)    Percent
load_text_encoder          0.21     17.34%
load_vae                   1.01     82.66%

[…]

Sampling: 100%|████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 64/64 [03:33<00:00,  3.33s/it]
moving model from cpu -> cuda:0████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████| 64/64 [03:33<00:00,  1.09it/s]
moving model from cuda:0 -> cpu
Moviepy - Building video finetunes/my_mochi_lora/samples/0_200.mp4.
Moviepy - Writing video finetunes/my_mochi_lora/samples/0_200.mp4
```

!!! note

    During the fine-tuning, you'll see messages similar to:

    ```text { .no-copy }
    W1126 16:46:47.939000 265211801175072 torch/fx/experimental/symbolic_shapes.py:4449] [2/0_1] xindex is not in var_ranges, defaulting to unknown range.
    W1126 16:46:51.271000 265211801175072 torch/fx/experimental/symbolic_shapes.py:4449] [2/1_1] xindex is not in var_ranges, defaulting to unknown range.
    W1126 16:46:53.847000 265211801175072 torch/fx/experimental/symbolic_shapes.py:4449] [2/2_1] xindex is not in var_ranges, defaulting to unknown range.
    W1126 16:46:56.411000 265211801175072 torch/fx/experimental/symbolic_shapes.py:4449] [2/3_1] xindex is not in var_ranges, defaulting to unknown range.
    ```

    These messages can safely be disregarded.

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
-  For more tips and tutorials, see our [Education](../../education/index.md)
    section.
