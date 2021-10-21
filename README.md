# clab-nanog83-advanced

This repo contains the [Containerlab](https://containerlab.srlinux.dev/) advanced example presented at NANOG83.

Here you can find the files needed to deploy the below topology

![nanog83-Page-1](https://user-images.githubusercontent.com/12892894/138223207-b4ad2ffd-57b7-48d1-8dbe-f5d16f11d151.png)


## Prerequisites

- Install [Docker](https://docs.docker.com/engine/install/)
- Install [Containerlab](https://containerlab.srlinux.dev/install/)
- Install [gNMIc](https://gnmic.kmrd.dev/install/)

## Deploy on local machine

Run:

```bash
bash run.sh
```

## Deploy via Github Actions

The repo includes a github [workflow](https://github.com/karimra/clab-nanog83-advanced/blob/main/.github/workflows/wf.yaml) that deploys the lab on a self-hosted runner.

![lab-gh-actions](https://user-images.githubusercontent.com/12892894/138225607-35f3bad3-5e05-4f37-a74f-f0840029cf0c.png)
