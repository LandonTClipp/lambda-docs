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
- [Use SkyPilot to launch 2 1x A10 on-demand instances and deploy a 2-node
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
pip3 install "skypilot-nightly[lambda,kubernetes]"
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

At the top of the file, for`SKY_K3S_TOKEN`, replace **mytoken** with a strong
passphrase.

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
  accelerators: A10:1
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

Then, launch 2 1x A10 instances and deploy a 2-node Kubernetes cluster using
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
SkyPilot collects usage data to improve its services. `setup` and `run` commands are not collected to ensure privacy.
Usage logging can be disabled by setting the environment variable SKYPILOT_DISABLE_USAGE_COLLECTION=1.
Task from YAML spec: cloud_k8s.yaml
I 09-11 16:10:04 optimizer.py:719] == Optimizer ==
I 09-11 16:10:04 optimizer.py:730] Target: minimizing cost
I 09-11 16:10:04 optimizer.py:742] Estimated cost: $1.5 / hour
I 09-11 16:10:04 optimizer.py:742]
I 09-11 16:10:04 optimizer.py:867] Considered resources (2 nodes):
I 09-11 16:10:04 optimizer.py:937] ------------------------------------------------------------------------------------------
I 09-11 16:10:04 optimizer.py:937]  CLOUD    INSTANCE     vCPUs   Mem(GB)   ACCELERATORS   REGION/ZONE   COST ($)   CHOSEN
I 09-11 16:10:04 optimizer.py:937] ------------------------------------------------------------------------------------------
I 09-11 16:10:04 optimizer.py:937]  Lambda   gpu_1x_a10   30      200       A10:1          us-east-1     1.50          ✔
I 09-11 16:10:04 optimizer.py:937] ------------------------------------------------------------------------------------------
I 09-11 16:10:04 optimizer.py:937]
Running task on cluster k8s...
I 09-11 16:10:04 cloud_vm_ray_backend.py:4397] Creating a new cluster: 'k8s' [2x Lambda(gpu_1x_a10, {'A10': 1})].
I 09-11 16:10:04 cloud_vm_ray_backend.py:4397] Tip: to reuse an existing cluster, specify --cluster (-c). Run `sky status` to see existing clusters.
I 09-11 16:10:05 cloud_vm_ray_backend.py:1314] To view detailed progress: tail -n100 -f /home/lambda/sky_logs/sky-2024-09-11-16-10-03-504822/provision.log
I 09-11 16:10:06 cloud_vm_ray_backend.py:1721] Launching on Lambda us-east-1
I 09-11 16:13:24 log_utils.py:45] Head node is up.
I 09-11 16:14:10 cloud_vm_ray_backend.py:1826] Successfully provisioned or found existing head instance. Waiting for workers.
I 09-11 16:18:13 cloud_vm_ray_backend.py:1569] Successfully provisioned or found existing VMs.
I 09-11 16:18:17 cloud_vm_ray_backend.py:3319] Job submitted with Job ID: 1
```

It usually takes about 15 minutes for the Kubernetes cluster to be deployed.

The Kubernetes cluster is successfully deployed once you see:

```{.text .no-copy}
Checking credentials to enable clouds for SkyPilot.
  Kubernetes: enabled
    Hint: Could not detect GPU labels in Kubernetes cluster. If this cluster has GPUs, please ensure GPU nodes have node labels of either of these formats: skypilot.co/accelerator, cloud.google.com/gke-accelerator, karpenter.k8s.aws/instance-gpu-name, nvidia.com/gpu.product, gpu.nvidia.com/class. Please refer to the documentation on how to set up node labels.

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
sky jobs launch --gpus A10 --cloud kubernetes -- 'nvidia-smi'
```

You'll see output similar to the following and will be asked if you want to
proceed:

```{.text .no-copy}
Task from command: nvidia-smi
Managed job 'sky-cmd' will be launched on (estimated):
I 09-07 16:26:18 optimizer.py:718] == Optimizer ==
I 09-07 16:26:18 optimizer.py:741] Estimated cost: $0.0 / hour
I 09-07 16:26:18 optimizer.py:741]
I 09-07 16:26:18 optimizer.py:866] Considered resources (1 node):
I 09-07 16:26:18 optimizer.py:936] ---------------------------------------------------------------------------------------------------
I 09-07 16:26:18 optimizer.py:936]  CLOUD        INSTANCE          vCPUs   Mem(GB)   ACCELERATORS   REGION/ZONE   COST ($)   CHOSEN
I 09-07 16:26:18 optimizer.py:936] ---------------------------------------------------------------------------------------------------
I 09-07 16:26:18 optimizer.py:936]  Kubernetes   2CPU--8GB--1A10   2       8         A10:1          kubernetes    0.00          ✔
I 09-07 16:26:18 optimizer.py:936] ---------------------------------------------------------------------------------------------------
I 09-07 16:26:18 optimizer.py:936]
Launching a managed job 'sky-cmd'. Proceed? [Y/n]:
```

Press ++enter++ to proceed.

You should see output similar to the following, indicating the job ran
successfully:

```{.text .no-copy}
Launching managed job 'sky-cmd' from jobs controller...
Launching jobs controller...
I 09-07 16:26:25 optimizer.py:718] == Optimizer ==
I 09-07 16:26:25 optimizer.py:741] Estimated cost: $0.0 / hour
I 09-07 16:26:25 optimizer.py:741]
I 09-07 16:26:25 optimizer.py:866] Considered resources (1 node):
I 09-07 16:26:25 optimizer.py:936] ----------------------------------------------------------------------------------------------
I 09-07 16:26:25 optimizer.py:936]  CLOUD        INSTANCE     vCPUs   Mem(GB)   ACCELERATORS   REGION/ZONE   COST ($)   CHOSEN
I 09-07 16:26:25 optimizer.py:936] ----------------------------------------------------------------------------------------------
I 09-07 16:26:25 optimizer.py:936]  Kubernetes   8CPU--24GB   8       24        -              kubernetes    0.00          ✔
I 09-07 16:26:25 optimizer.py:936] ----------------------------------------------------------------------------------------------
I 09-07 16:26:25 optimizer.py:936]
I 09-07 16:26:25 cloud_vm_ray_backend.py:4354] Creating a new cluster: 'sky-jobs-controller-0b36a124' [1x Kubernetes(8CPU--24GB, cpus=8+, mem=3x, disk_size=50)].
I 09-07 16:26:25 cloud_vm_ray_backend.py:4354] Tip: to reuse an existing cluster, specify --cluster (-c). Run `sky status` to see existing clusters.
I 09-07 16:26:25 cloud_vm_ray_backend.py:1314] To view detailed progress: tail -n100 -f /home/c/sky_logs/sky-2024-09-07-16-26-24-870809/provision.log
I 09-07 16:26:25 common.py:228] Updated Kubernetes catalog.
I 09-07 16:26:25 provisioner.py:62] Launching on Kubernetes 'sky-jobs-controller-0b36a124'.
I 09-07 16:26:47 provisioner.py:450] Successfully provisioned or found existing instance.
I 09-07 16:27:10 provisioner.py:552] Successfully provisioned cluster: sky-jobs-controller-0b36a124
I 09-07 16:27:10 cloud_vm_ray_backend.py:4383] Processing file mounts.
I 09-07 16:27:10 cloud_vm_ray_backend.py:4409] To view detailed progress: tail -n100 -f ~/sky_logs/sky-2024-09-07-16-26-24-870809/file_mounts.log
I 09-07 16:27:10 backend_utils.py:1336] Syncing (to 1 node): /tmp/managed-dag-sky-cmd-0gu861ix -> ~/.sky/managed_jobs/sky-cmd-1b6c.yaml
I 09-07 16:27:13 cloud_vm_ray_backend.py:3176] Running setup on 1 node.
Check & install cloud dependencies on controller: Done for 1 clouds.
I 09-07 16:27:16 cloud_vm_ray_backend.py:3189] Setup completed.
I 09-07 16:27:16 cloud_vm_ray_backend.py:4109] Auto-stop is not supported for Kubernetes and RunPod clusters. Skipping.
I 09-07 16:27:20 cloud_vm_ray_backend.py:3276] Job submitted with Job ID: 1
I 09-07 23:28:46 log_lib.py:412] Start streaming logs for managed job 1.
INFO: Tip: use Ctrl-C to exit log streaming (task will not be killed).
INFO: Waiting for task resources on 1 node. This will block if the cluster is full.
INFO: All task resources reserved.
INFO: Reserved IPs: ['10.42.1.16']
(sky-cmd, pid=1504) Sat Sep  7 23:28:31 2024
(sky-cmd, pid=1504) +---------------------------------------------------------------------------------------+
(sky-cmd, pid=1504) | NVIDIA-SMI 535.129.03             Driver Version: 535.129.03   CUDA Version: 12.2     |
(sky-cmd, pid=1504) |-----------------------------------------+----------------------+----------------------+
(sky-cmd, pid=1504) | GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
(sky-cmd, pid=1504) | Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
(sky-cmd, pid=1504) |                                         |                      |               MIG M. |
(sky-cmd, pid=1504) |=========================================+======================+======================|
(sky-cmd, pid=1504) |   0  NVIDIA A10                     On  | 00000000:07:00.0 Off |                    0 |
(sky-cmd, pid=1504) |  0%   30C    P8              22W / 150W |      4MiB / 23028MiB |      0%      Default |
(sky-cmd, pid=1504) |                                         |                      |                  N/A |
(sky-cmd, pid=1504) +-----------------------------------------+----------------------+----------------------+
(sky-cmd, pid=1504)
(sky-cmd, pid=1504) +---------------------------------------------------------------------------------------+
(sky-cmd, pid=1504) | Processes:                                                                            |
(sky-cmd, pid=1504) |  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
(sky-cmd, pid=1504) |        ID   ID                                                             Usage      |
(sky-cmd, pid=1504) |=======================================================================================|
(sky-cmd, pid=1504) |  No running processes found                                                           |
(sky-cmd, pid=1504) +---------------------------------------------------------------------------------------+
I 09-07 23:28:54 utils.py:447] Logs finished for job 1 (status: SUCCEEDED).

I 09-07 16:28:54 cloud_vm_ray_backend.py:3292] Managed Job ID: 1
I 09-07 16:28:54 cloud_vm_ray_backend.py:3292] To cancel the job:		sky jobs cancel 1
I 09-07 16:28:54 cloud_vm_ray_backend.py:3292] To stream job logs:		sky jobs logs 1
I 09-07 16:28:54 cloud_vm_ray_backend.py:3292] To stream controller logs:	sky jobs logs --controller 1
I 09-07 16:28:54 cloud_vm_ray_backend.py:3292] To view all managed jobs:	sky jobs queue
I 09-07 16:28:54 cloud_vm_ray_backend.py:3292] To view managed job dashboard:	sky jobs dashboard
```
