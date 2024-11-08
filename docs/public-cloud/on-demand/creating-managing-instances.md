---
description: Describes how to create and manage instances on Lambda On-Demand Cloud.
tags:
  - on-demand cloud
---

# Creating and managing instances

This doc outlines how to create and manage On-Demand Cloud (ODC) instances. For
general guidance on managing your ODC instance's system environment, see
[Managing your system environment](managing-system-environment.md).

## Viewing available instance types

To view available instance types, navigate to the
[Instances page](https://cloud.lambdalabs.com/instances){: target="_blank" .external }
in the Lambda Cloud console and click **Launch instance** to start the
instance creation wizard. The first page of the wizard dialog lists all of
the instance types Lambda currently offers.

You can also programmatically view available instance types by using the Lambda
Cloud API. For details, see
[Cloud API &gt; Retrieving list of offered instance types](../cloud-api.md#listing-instances-types-offered-by-lambda-gpu-cloud).

## Launching instances

To launch a new instance, navigate to the
[Instances page](https://cloud.lambdalabs.com/instances){: target="_blank" .external }
in the Lambda Cloud console, click **Launch instance**, and then follow the
steps in the instance creation wizard.

!!! note

    Instances might take several minutes to launch.

You can also launch instances programmatically by using the Lambda Cloud API
For details, see
[Cloud API &gt; Launching instances](../cloud-api.md#launching-instances).

## Viewing instance metadata

### Listing your instances

To view a list of your running instances, visit the
[Instances page](https://cloud.lambdalabs.com/instances){: target="_blank" .external }
in the Lambda Cloud console.

You can also retrieve more detailed information about your instances, including
their IDs, private IPs, and attached filesystems, by using the Lambda Cloud API.
For details, see
[Cloud API &gt; Listing details of running instances](../cloud-api.md#listing-details-of-running-instances).

### Viewing instance usage

To view your monthly usage, navigate to the
[Usage page](https://cloud.lambdalabs.com/usage){: target="_blank" .external }
in the Lambda Cloud console and then click the **Instances** tab.

## Restarting an instance

To restart one or more instances:

1. Navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){: target="_blank" .external }
    in the Lambda Cloud console.
1. In the instance list, click the checkbox for each instance you want to
    restart.
1. Click **Restart** to restart your instances. The **Restart** button is
    located on the right side of the page above the instance list.

You can also restart instances programmatically by using the Lambda Cloud API.
For details, see
[Cloud API &gt; Restarting instances](../cloud-api.md#restarting-instances).

!!! warning "Important"

    To use this API method, you need the ID of each instance you want to
    restart. You can retrieve these instance IDs programmatically by using the
    [List running instances](../cloud-api.md#listing-details-of-running-instances)
    method in the Lambda Cloud API.

## Terminating an instance

To terminate one or more instances:

1. Navigate to the
    [Instances page](https://cloud.lambdalabs.com/instances){: target="_blank" .external }
    in the Lambda Cloud console.
1. In the instance list, click the checkbox for each instance you want to
    restart.
1. Click **Terminate** to terminate your instances. The **Terminate** button is
    located on the right side of the page above the instance list.

You can also terminate instances programmatically by using the Lambda Cloud API.
For details, see
[Cloud API &gt; Terminating instances](../cloud-api.md#terminating-instances).

!!! warning "Important"

    To use this API method, you need the ID of each instance you want to
    terminate. You can retrieve these instance IDs programmatically by using the
    [List running instances](../cloud-api.md#listing-details-of-running-instances)
    method in the Lambda Cloud API.

## Suspending an instance

At the moment, Lambda Cloud instances can only be launched, restarted, or
terminated. To preserve state, we recommend using Docker to containerize your
environment and performing regular backups of important data. For detailed
guidance, see Importing and exporting data.

## Next steps

-  New to ODC? Check out the [ODC Overview](index.md).
-  For more information on the methods available in the Lambda Cloud API,
    see [Cloud API](../cloud-api.md).
