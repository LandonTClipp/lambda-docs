---
description: Lambda and SkyPilot make it easy to deploy a Kubernetes cluster. Read this tutorial to learn more.

tags:
  - api
  - kubernetes
title: Using SkyPilot to deploy a Kubernetes cluster
---

!!! note

    [**Apply for Cloud Credits and experiment with this tutorial—for
    free!**](https://lambdalabs.com/skypilot-tutorial-cloud-credits)

# Using SkyPilot to deploy a Kubernetes cluster

## Introduction

[SkyPilot
:octicons-link-external-16:](https://skypilot.readthedocs.io/en/latest/docs/index.html){target="_blank"}
makes it easy to deploy a Kubernetes cluster using [Lambda Public Cloud
:octicons-link-external-16:](https://lambdalabs.com/service/gpu-cloud){target="_blank"}
on-demand instances. The [NVIDIA GPU Operator
:octicons-link-external-16:](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html){target="_blank"}
is preinstalled so you can immediately use your instances' GPUs.

In this tutorial, you'll:

- [Configure your Lambda Public Cloud Firewall and a Cloud API key for SkyPilot
  and
  Kubernetes](#configure-your-lambda-public-cloud-firewall-and-generate-a-cloud-api-key).
- [Install SkyPilot](#install-skypilot).
- [Configure SkyPilot for Lambda Public
  Cloud](#configure-skypilot-for-lambda-public-cloud).
- [Use SkyPilot to launch 2 1x H100 on-demand instances and deploy a 2-node
  Kubernetes cluster using these
  instances](#use-skypilot-to-launch-instances-and-deploy-kubernetes).

!!! note

    [**You're billed for all of the time the instances are
    running.**](https://docs.lambdalabs.com/on-demand-cloud/billing#how-are-on-demand-instances-billed)

All of the instructions in this tutorial should be followed on your computer.

This tutorial assumes you already have installed:

- `python3`
- `python3-venv`
- `python3-pip`
- `curl`
- `netcat`
- `socat`

You can install these packages by running:

```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl netcat socat
```

You also need to install
[kubectl :octicons-link-external-16:](https://kubernetes.io/docs/reference/kubectl/) by running:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

## Configure your Lambda Public Cloud Firewall and generate a Cloud API key

Use the [Lambda Public Cloud Firewall
feature](https://docs.lambdalabs.com/on-demand-cloud/firewall) to add rules
allowing incoming traffic to ports TCP/443 and TCP/6443.

[Generate a Cloud API
key](https://docs.lambdalabs.com/on-demand-cloud/dashboard#generate-and-delete-api-keys)
for SkyPilot. You can also use an existing Cloud API key.

## Install SkyPilot

Create a directory for this tutorial and change into the directory by running:

```bash
mkdir ~/skypilot-tutorial && cd ~/skypilot-tutorial
```

Create and activate a Python virtual environment for this tutorial by running:

```bash
python3 -m venv ~/skypilot-tutorial/.venv && source ~/skypilot-tutorial/.venv/bin/activate
```

Then, install SkyPilot in your virtual environment by running:

```bash
pip3 install skypilot-nightly[lambda,kubernetes]
```

## Configure SkyPilot for Lambda Public Cloud

Download the SkyPilot example [`cloud_k8s.yaml`
:octicons-link-external-16:](https://github.com/skypilot-org/skypilot/blob/master/examples/k8s_cloud_deploy/cloud_k8s.yaml){target="_blank"}
and [`launch_k8s.sh`
:octicons-link-external-16:](https://github.com/skypilot-org/skypilot/blob/master/examples/k8s_cloud_deploy/launch_k8s.sh){target="_blank"}
files by running:

```bash
curl -LO https://raw.githubusercontent.com/skypilot-org/skypilot/master/examples/k8s_cloud_deploy/cloud_k8s.yaml && \
curl -LO https://raw.githubusercontent.com/skypilot-org/skypilot/master/examples/k8s_cloud_deploy/launch_k8s.sh
```

Edit the `cloud_k8s.yaml` file.

At the top of the file:

- Set `accelerators` to `H100:1`.
- For`SKY_K3S_TOKEN`, replace **mytoken** with a strong passphrase.

!!! warning

    **It's important that you use a strong passphrase.** Otherwise, the
    Kubernetes cluster can be compromised, especially if your [firewall
    rules](#configure-your-lambda-public-cloud-firewall-and-generate-a-cloud-api-key)
    allow incoming traffic from all sources.

    You can generate a strong passphrase by running:

    ```bash
    openssl rand -base64 16
    ```

    This command will generate a random string of characters such as
    `zPUlZGe4HRcy+Om04RvGmQ==`.

The top of the `cloud_k8s.yaml` file should look similar to:

```yaml
resources:
  cloud: lambda
  accelerators: H100:1
#  Uncomment the following line to expose ports on a different cloud
#  ports: 6443

num_nodes: 2

envs:
  SKY_K3S_TOKEN: zPUlZGe4HRcy+Om04RvGmQ== # Can be any string, used to join worker nodes to the cluster
```

!!! note

    You can set `accelerators` to a different instance type, for example,
    `A100:8` for an 8x A100 instance or `H100:8` for an 8x H100 instance.

Create a directory in your home directory named `.lambda_cloud` and change into
that directory by running:

```bash
mkdir -m 700 ~/.lambda_cloud && cd ~/.lambda_cloud
```

Create a file named `lambda_keys` that contains:

```
api_key = API-KEY
```

!!! tip

    You can do this by running:

    ```bash
    echo "api_key = API-KEY" > lambda_keys
    ```

Replace **API-KEY** with your actual Cloud API key.

## Use SkyPilot to launch instances and deploy Kubernetes

Change into the directory you created for this tutorial by running:

```bash
cd ~/skypilot-tutorial
```

Then, launch 2 1x H100 instances and deploy a 2-node Kubernetes cluster using
those instances by running:

```bash
bash launch_k8s.sh
```

You'll begin to see output similar to:

```{.text .no-copy}
===== SkyPilot Kubernetes cluster deployment script =====
This script will deploy a Kubernetes cluster on the cloud and GPUs specified in cloud_k8s.yaml.

+ CLUSTER_NAME=k8s
+ sky launch -y -c k8s cloud_k8s.yaml
Task from YAML spec: cloud_k8s.yaml
Considered resources (2 nodes):
------------------------------------------------------------------------------------------------
 CLOUD    INSTANCE           vCPUs   Mem(GB)   ACCELERATORS   REGION/ZONE   COST ($)   CHOSEN
------------------------------------------------------------------------------------------------
 Lambda   gpu_1x_h100_pcie   26      200       H100:1         us-east-1     4.98          ✔
------------------------------------------------------------------------------------------------
Multiple Lambda instances satisfy H100:1. The cheapest Lambda(gpu_1x_h100_pcie, {'H100': 1}) is considered among:
['gpu_1x_h100_pcie', 'gpu_1x_h100_sxm5'].
To list more details, run: sky show-gpus H100

Running task on cluster k8s...
```

It usually takes about 15 minutes for the Kubernetes cluster to be deployed.

The Kubernetes cluster is successfully deployed once you see:

```{.text .no-copy}
Checking credentials to enable clouds for SkyPilot.
  Kubernetes: enabled

To enable a cloud, follow the hints above and rerun: sky check
If any problems remain, refer to detailed docs at: https://skypilot.readthedocs.io/en/latest/getting-started/installation.html

🎉 Enabled clouds 🎉
  ✔ Kubernetes
  ✔ Lambda
+ set +x
===== Kubernetes cluster deployment complete =====
You can now access your k8s cluster with kubectl and skypilot.

• View the list of available GPUs on Kubernetes: sky show-gpus --cloud kubernetes
• To launch a SkyPilot job running nvidia-smi on this cluster: sky launch --cloud kubernetes --gpus <GPU> -- nvidia-smi
```

To test the Kubernetes cluster, launch a [job
:octicons-link-external-16:](https://skypilot.readthedocs.io/en/latest/examples/managed-jobs.html){target="_blank"}
by running:

```bash
sky jobs launch --gpus H100 --cloud kubernetes -- 'nvidia-smi'
```

You'll see output similar to the following and will be asked if you want to
proceed:

```{.text .no-copy}
Task from command: nvidia-smi
Managed job 'sky-cmd' will be launched on (estimated):
Considered resources (1 node):
----------------------------------------------------------------------------------------------------
 CLOUD        INSTANCE           vCPUs   Mem(GB)   ACCELERATORS   REGION/ZONE   COST ($)   CHOSEN
----------------------------------------------------------------------------------------------------
 Kubernetes   2CPU--8GB--1H100   2       8         H100:1         default       0.00          ✔
----------------------------------------------------------------------------------------------------
Launching a managed job 'sky-cmd'. Proceed? [Y/n]: y
```

Press ++enter++ to proceed.

You should see output similar to the following, indicating the job ran
successfully:

```{.text .no-copy}
Launching managed job 'sky-cmd' from jobs controller...
Considered resources (1 node):
----------------------------------------------------------------------------------------------
 CLOUD        INSTANCE     vCPUs   Mem(GB)   ACCELERATORS   REGION/ZONE   COST ($)   CHOSEN
----------------------------------------------------------------------------------------------
 Kubernetes   8CPU--24GB   8       24        -              default       0.00          ✔
----------------------------------------------------------------------------------------------
⚙︎ Launching managed jobs controller on Kubernetes.
└── Pod is up.
✓ Cluster launched: sky-jobs-controller-4b0a835a.  View logs at: ~/sky_logs/sky-2024-11-07-08-48-26-378180/provision.log
⚙︎ Mounting files.
  Syncing (to 1 node): /tmp/managed-dag-sky-cmd-nza5s28e -> ~/.sky/managed_jobs/sky-cmd-4bfa.yaml
✓ Files synced.  View logs at: ~/sky_logs/sky-2024-11-07-08-48-26-378180/file_mounts.log
⚙︎ Running setup on managed jobs controller.
  Check & install cloud dependencies on controller: done.
✓ Setup completed.  View logs at: ~/sky_logs/sky-2024-11-07-08-48-26-378180/setup-*.log
Auto-stop is not supported for Kubernetes and RunPod clusters. Skipping.
⚙︎ Job submitted, ID: 1
├── Waiting for task resources on 1 node.
└── Job started. Streaming logs... (Ctrl-C to exit log streaming; job will not be killed)
(sky-cmd, pid=1362) Thu Nov  7 16:52:15 2024
(sky-cmd, pid=1362) +-----------------------------------------------------------------------------------------+
(sky-cmd, pid=1362) | NVIDIA-SMI 550.90.12              Driver Version: 550.90.12      CUDA Version: 12.4     |
(sky-cmd, pid=1362) |-----------------------------------------+------------------------+----------------------+
(sky-cmd, pid=1362) | GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
(sky-cmd, pid=1362) | Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
(sky-cmd, pid=1362) |                                         |                        |               MIG M. |
(sky-cmd, pid=1362) |=========================================+========================+======================|
(sky-cmd, pid=1362) |   0  NVIDIA H100 PCIe               On  |   00000000:08:00.0 Off |                    0 |
(sky-cmd, pid=1362) | N/A   32C    P0             49W /  350W |       1MiB /  81559MiB |      0%      Default |
(sky-cmd, pid=1362) |                                         |                        |             Disabled |
(sky-cmd, pid=1362) +-----------------------------------------+------------------------+----------------------+
(sky-cmd, pid=1362)
(sky-cmd, pid=1362) +-----------------------------------------------------------------------------------------+
(sky-cmd, pid=1362) | Processes:                                                                              |
(sky-cmd, pid=1362) |  GPU   GI   CI        PID   Type   Process name                              GPU Memory |
(sky-cmd, pid=1362) |        ID   ID                                                               Usage      |
(sky-cmd, pid=1362) |=========================================================================================|
(sky-cmd, pid=1362) |  No running processes found                                                             |
(sky-cmd, pid=1362) +-----------------------------------------------------------------------------------------+
✓ Managed job finished: 1 (status: SUCCEEDED).


📋 Useful Commands
Managed Job ID: 1
├── To cancel the job:              sky jobs cancel 1
├── To stream job logs:             sky jobs logs 1
├── To stream controller logs:      sky jobs logs --controller 1
├── To view all managed jobs:       sky jobs queue
└── To view managed job dashboard:  sky jobs dashboard
```
