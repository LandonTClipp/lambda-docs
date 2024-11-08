---
description: Learn how to import data into, and export data from, Lamdba Cloud instances and nodes.
tags:
  - 1-click clusters
  - on-demand cloud
---

# Importing and exporting data

This document outlines common solutions for importing data into your Lambda
On-Demand Cloud (ODC) instances and 1-Click Clusters (1CCs). The document also
provides guidance on backing up your data so that it persists beyond the life of
your instance or 1CC.

## Importing data

You can use `rsync` to copy data to and from your Lambda instances and their
attached filesystems. `rsync` allows you to copy files from your local
environment to your ODC instance, between ODC instances, from instances to 1CCs,
and more. If you need to import data from AWS S3 or an S3-compatible object
storage service like Cloudflare R2, Google Cloud Storage, or Minio, you can use
`s5cmd` or `rclone`.

### Importing data from your local environment

To copy files from your local environment to a Lambda Cloud instance or cluster,
run the following `rsync` command from your local terminal. Replace the
variables as follows:

-  Replace `<FILES>` with the files or directories you want to copy to the
    remote instance. If you're copying multiple files or directories, separate
    them using spaces—for example, `foo.md bar/ baz/`.
-  Replace `<USERNAME>` with your username on the remote instance.
-  Replace `<SERVER-IP> `with the IP address of the remote instance.
-  Replace `<REMOTE-PATH>` with the directory into which you want to copy files.

```
rsync -av --info=progress2 <FILES> <USERNAME>@<SERVER-IP>:<REMOTE-PATH>
```

### Copying data between instances

To copy files directly between remote servers using `rsync`, you must use public
key authentication for SSH with an SSH agent. To add your private key to the SSH
agent, run `ssh-add`, replacing `<PRIVATE-KEY-PATH>` with the path to your SSH
private key (for example, `~/.ssh/id_ed25519a`):

```bash
ssh-add <PRIVATE-KEY-PATH>
```

You can confirm your key was added to the SSH agent by running:

```bash
ssh-add -L
```

You should see your public key in the output.

After you add your private key to your SSH agent, you can copy files directly
between remote servers:

1. Establish an SSH connection to the server you're copying files from.
    Replace `<SERVER-IP>` with the IP address of the server, and replace
    `<USERNAME>` with your username on that server.

    ```bash
    ssh -A <USERNAME>@<SERVER-IP>
    ```

1. On that server, start a `screen` session for your copy operation,
    replacing `<SESSION-NAME>` with an appropriate session name. `screen` lets
    you create and manage multiple terminal sessions within a single terminal
    window or tab.

    ```bash
    screen -S <SESSION-NAME>
    ```

1. Copy files to your remote destination server. Replace `<FILES>` with the
    files or directory you want to copy, `<USERNAME>` with your username on the
    server, `<SERVER-IP>` with the server's IP address, and `<REMOTE-PATH>`
    with the directory into which you want to copy your files.

    ```bash
    rsync -av --info=progress2 <FILES> <USERNAME>@<SERVER-IP>:<REMOTE-PATH>
    ```

1. Optionally, detach your `screen` session by pressing ++ctrl++ + ++a++, then
    ++d++. You can resume the session by running `screen -r <SESSION-NAME>`,
    replacing `<SESSION-NAME>` with the session name you chose in step 2.

### Importing data from S3 or S3-compatible object storage

To import data from AWS S3 or S3-compatible object storage services like Google
Cloud Storage, Cloudflare R2, or MinIO, you can use a command line tool that
supports parallelized import, such as `s5cmd` or `rclone`. These solutions are
optimized to move large amounts of data and are typically much faster than
`rsync`, `scp`, `s3`, and other common file import solutions.

#### Import with s5cmd

First, install `s5cmd` on your instance or node:

1. Navigate to the
    [`s5cmd` releases page](https://github.com/peak/s5cmd/releases){ target="_blank" .external }.
    Copy the link for the latest AMD64 .deb release.
1. Establish an SSH connection to your instance or node.
1. In your SSH terminal, download the release to your instance or node.
    Replace `<RELEASE-URL>` with the URL you copied in step 1:

    ```bash
    wget <RELEASE-URL>
    ```

1. Install the release. Replace `<DEB-FILENAME>` with the filename of your
    downloaded Debian package. Make sure to keep the `./` in front of the filename:

    ```bash
    sudo apt install ./<DEB-FILENAME>
    ```

After you install `s5cmd`, set up your environment and then begin importing your
data:

1. Open your `.bashrc` file for editing:

    ```bash
    nano ~/.bashrc
    ```

1. At the bottom of the file, set the required environment variables, and
    then save and exit:

    ```bash
    export AWS_ACCESS_KEY_ID='<ACCESS-KEY-ID>'
    export AWS_SECRET_ACCESS_KEY='<SECRET-ACCESS-KEY>'
    export AWS_PROFILE='<PROFILE-NAME>'
    export AWS_REGION='<BUCKET-REGION>'
    ```

    !!! note

        `s5cmd` supports other methods of specifying credentials as well. For
        details, see the
        [Specifying credentials](https://github.com/peak/s5cmd?tab=readme-ov-file#specifying-credentials){ target="_blank" .external }
        section of the `s5cmd` documentation.

1. Update your environment with your new environment variables:

    ```bash
    source ~/.bashrc
    ```

1. Verify that your credentials are working as expected by listing the
    files in your source bucket. Replace `<S3-BUCKET>` with the S3-compatible
    bucket from which you're importing data:

    ```bash
    s5cmd ls s3://<S3-BUCKET>
    ```

1. Navigate to the directory into which you want to import your data.
1. Use `s5cmd` to import the data. Replace `<S3-BUCKET-PATH>` with the path
    to your files inside your S3-compatible bucket:

    ```bash
    s5cmd cp '<S3-BUCKET-PATH>' .
    ```

    You can use wildcards to filter the content you import. For example, the
    following command imports the files and file structure of `foo` and its
    subdirectories:

    ```bash
    s5cmd cp 's3://example-bucket/foo/*' .
    ```

To help optimize your data transfer, you can add the following flags to the
`s5cmd` command.

| Flag                | Function                                                                                                    |
| ------------------- | ----------------------------------------------------------------------------------------------------------- |
|  `--concurrency N`  | Sets the number of parts that will be uploaded or downloaded in parallel for a single file. Default is `5`. |
|  `--dry-run`        | Outputs which operations will be performed without actually carrying out those operations.                  |
|  `--numworkers N`   | Sets the size of the global worker pool. In practice, acts as an upper bound for how many files can be uploaded or downloaded concurrently. Default is `256`. |
|  `--retry-count N`  | Sets the maximum number of retries for failed operations. Default is `10`.                                  |

For more guidance on using `s5cmd` to import your data, see
[`s5cmd` on GitHub](https://github.com/peak/s5cmd){ target="_blank" .external } .

#### Import with rclone

To import data from an S3-compatible storage solution using `rclone`:

1. Establish an SSH connection to your instance or node.
1. Install `rclone`. For installation instructions, see
    [Install](https://rclone.org/install/){ target="_blank" .external }  in the Rclone documentation.
1. Configure `rclone`. Follow the series of prompts to create a new remote
    and then set the source storage service, your credentials for that service,
    the region in which your data is stored, and other details:

    ```bash
    rclone config
    ```

1. After you complete the configuration process, verify your connection by
    listing the contents of your source storage bucket. Replace `<REMOTE>` with
    the name of your remote and `<BUCKET-NAME>` with the name of your source
    bucket:

    ```bash
    rclone ls <REMOTE>:<BUCKET-NAME>
    ```

    For example, the following command lists the contents of a bucket named
    `example-bucket`:

    ```bash
    rclone ls my-remote:example-bucket
    ```

1. Navigate to the directory into which you want to import your data.
1. Import your data. Replace `<REMOTE>` with the name of your remote,
    `<BUCKET-NAME>` with the name of your source bucket, and `<LOCAL-DIR>` with
    the path to the directory to which you're importing the data:

    ```bash
    rclone -P copy <REMOTE>:<BUCKET-NAME> <LOCAL-DIR>
    ```

You can optimize your data transfer by adding flags to your `rclone` command.
Particularly useful flags include:

| Flag                       | Function                                                                                           |
| -------------------------- | -------------------------------------------------------------------------------------------------- |
|   `--checkers N`           | Number of file integrity and status checkers to run in parallel. Default is `8`.                   |
|   `--dry-run`              | Outputs which operations will be performed without actually carrying out  those operations.        |
|   `--low-level-retries N`  | Sets the maximum number of retries for failed API-level operations such as reads. Default is `10`. |
|   `--transfers N`          | Number of file transfers to run in parallel. Default is `4`.                                       |
|   `--retries N`            | Sets the maximum number of retries for failed transfers. Default is `10`.                          |
|   `--timeout duration`     | Sets timeout for blocking network failures. Default is `5m0s`.                                     |

For a list of additional flags that might be useful, see
[Global Flags](https://rclone.org/flags/){ target="_blank" .external }
in the Rclone docs. For general information about `rclone`, see
[Rclone](https://rclone.org/){ target="_blank" .external }.

## Exporting data

When you terminate an ODC instance or your 1CC reservation ends, all local,
non-filesystem data is destroyed. To preserve your data, you should perform
regular backups.

!!! warning

    We cannot recover your data once you've terminated your instance.
    Before terminating an instance, make sure to back up any data that you
    want to keep.

!!! tip

    Virtual environments can help simplify the backup process by isolating
    and centralizing your system state into a small set of directories. For
    details on setting up an isolated virtual environment, see
    [Managing your system environment > Isolating environments on your instance](on-demand/managing-system-environment.md#isolating-environments-on-your-instance).

### Backing up data to a Lambda filesystem

You can persist your data on Lambda Cloud by backing the data up to an attached
filesystem. In the default configuration, your Lambda filesystem is mounted in
the following location:

```text
/home/ubuntu/<FILESYSTEM-NAME>
```

!!! warning "Important"

    To back up to a filesystem, the filesystem must be attached to
    your instance before you start your instance. You can't attach a
    filesystem to your instance after you start your instance.

### Backing up data to S3-compatible object storage

If you'd prefer to back up your data to an S3-compatible object storage service,
you can use the same tools and commands outlined in the
[Importing data from S3 or S3-compatible object storage](#importing-data-from-s3-or-s3-compatible-object-storage)
section. Instead of copying data from an S3-compatible bucket into your Lambda
instance or node, you copy your data from the instance or node into your
bucket.
