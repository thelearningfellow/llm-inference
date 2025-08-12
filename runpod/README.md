# General Runpod Setup

Install runpod cli
```sh
brew install runpod/runpodctl/runpodctl
```

and after that you would need to setup the CLI with the API keys. Follow this guide: https://docs.runpod.io/runpodctl/overview

Setup SSH keys. Follow this guide: https://docs.runpod.io/pods/configuration/use-ssh

Make sure to create a `.env` file in this directory with `RUNPOD_API_KEY` environment variable that is then used by the scripts.

## Building the docker container
I use the following command to build the docker image and push it

```sh
  docker buildx build \
  --platform linux/amd64 \
  --tag mbilalkaust/vllm:<VLLM-VERSION> \
  --push  .
```