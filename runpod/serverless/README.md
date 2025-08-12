# Deploying LLMs in Serverless Mode

Serverless tested with `vllm 0.9.1`

Models tested: `microsoft/Phi-4-mini-instruct`

with runpod docker image: `runpod/worker-v1-vllm:v2.7.0stable-cuda12.1.0`

How to send requests to the serverless endpoint
```sh
ENDPOINT_ID=0fsraa5ocov4kd
ENDPOINT=https://api.runpod.ai/v2/${ENDPOINT_ID}/openai

curl ${ENDPOINT}/v1/chat/completions \
    -X POST \
    -H "Authorization: Bearer ${RUNPOD_API_KEY}" \
    -H 'Content-Type: application/json' \
    -d '{
      "model": "Qwen/Qwen3-4B-Instruct-2507",
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
    }' | jq
```

Doing some load testing
```sh
hey -n 10 -c 2 \
  -m POST \
  -H "Authorization: Bearer $RUNPOD_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen3-4B-Instruct-2507",
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
    "max_tokens": 512
  }' \
  ${ENDPOINT}/v1/chat/completions
```




Request data to the /run endpoint
```json
{
  "input": {
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "Please write 500 words about the fall of Greece."
      }
    ]
  }
}
```