# Deploying LLMs on Slurm 
This file contains instructions on how to deploy LLMs using vLLM on Slurm in ROCS cluster.


## Creating mamba environment
Create the virtual env for vllm
```sh
mamba create -n vllm-env python=3.11
mamba activate vllm-env
mamba install cuda -c nvidia
pip install vllm==0.10.0
```

If you need to deploy a multi-replica setups then you should also create the virtual env for litellm proxy
```sh
mamba create -n litellm-env python=3.11
mamba activate litellm-env
pip install 'litellm[proxy]'
```

Right now using the same virtual environment for both of them creates some conflicts.

## Start vllm instance(s)
Start instance 1 of vLLM
```sh
srun --gres=gpu:a100:1 --time=1:00:00 --pty bash -i
source .bash_profile
mamba activate vllm-env
vllm serve --api-key sk-1234 --port 8000 microsoft/Phi-4-mini-instruct
```

Start instance 2 of vLLM
```sh
srun --gres=gpu:a100:1 --time=1:00:00 --pty bash -i
source .bash_profile
mamba activate vllm-env
vllm serve --api-key sk-1234 --port 8001 microsoft/Phi-4-mini-instruct
```

Get the IPs of both nodes using. We need this for the URL of the instances
```sh
hostname -I | awk '{print $1}'
```


Launch litellm proxy (if you want to work with multiple instances of vLLM)
```sh
srun --cpus-per-task=1 --time=0:10:00 --pty bash -i
source .bash_profile
mamba activate litellm-env
litellm --config ~/config.yaml --detailed_debug
```

`config.yaml` contains the configuration needed to register the two instances of vLLM (using their endpoint) to the model name.


Sending a request Litellm proxy:
```sh
export ENDPOINT=http://172.18.0.12:4000
curl ${ENDPOINT}/v1/chat/completions \
    -X POST \
    -H 'Authorization: Bearer sk-1234' \
    -H 'Content-Type: application/json' \
    -d '{
      "model": "microsoft/Phi-4-mini-instruct",
      "messages": [
        {
          "role": "system",
          "content": "You are a helpful assistant."
        },
        {
          "role": "user",
          "content": "What is Deep Learning?"
        }
      ],
      "max_tokens": 128
    }'
```

## Batch inference with Slurm
```sh
sbatch batch-inference-script.sh -i inputs.jsonl -o results.jsonl --model microsoft/Phi-4-mini-instruct
```

## Benchmarking using hey load-testing tool
```sh
hey -n 10 -c 2 \
  -m POST \
  -H "Authorization: Bearer sk-1234" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "microsoft/Phi-4-mini-instruct",
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "What is Deep Learning?"
      }
    ],
    "max_tokens": 128
  }' \
  ${ENDPOINT}/v1/chat/completions
```

## Notes
- We have to use pip to install vllm as that's the recommended way and install through conda creates issues as mentioned in the vllm documentation
- Currently facing problems while trying to install flashinfer 