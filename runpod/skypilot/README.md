## Setup
Install the dependencies
```sh
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Start the Sky API server
```sh
sky api start
```

Check the status of infrastucture
```sh
sky check
```

If the cloud isn't configured then run the following command
```sh
runpod config
```

Check the available GPUs
```sh
sky show-gpus --infra runpod -a
```

## Start a single replica of vLLM with OpenAI compatible API
```sh
skypilot % sky launch -c vllm single-replica.yaml
```

```sh
ENDPOINT=http://69.30.85.126:22149
curl -L $ENDPOINT/v1/chat/completions \
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
      "content": "Who are you?"
    }
    ]
  }' | jq
```

## Start a service: 
```sh
sky serve up -n vllm multi-replica.yaml
```

Check the status of a service
```sh
sky serve  status vllm
```

## Tear down
First tear down the service `sky serve down <service-name>`
If the cluster is stuck hanging, delete it with `sky down <cluster-name>`


## Calling endpoint
```sh
ENDPOINT=$(sky serve status --endpoint 8000 vllm)
hey -n 10 -c 2 \
  -m POST \
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
  ${ENDPOINT}$/v1/chat/completions
```
```sh
curl -L $ENDPOINT/v1/chat/completions \
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
      "content": "Who are you?"
    }
    ]
  }'
```

## Notes
- Seems like not all of the instances available on runpod are available via Skypilot. So their code for runpod is outdated.
- Currently skypilot has long setup as it is installing everything. We need to have a custom image. 