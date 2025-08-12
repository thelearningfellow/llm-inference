# Deploying LLMs in Pods on Runpod
When launching a pod, use the latest docker image [here](https://hub.docker.com/repository/docker/mbilalkaust/vllm/general). The `Dockerfile` used to create the docker image is in this repo. 
The current latest version is: `mbilalkaust/vllm:0.10.0`

The reason why we are using this custom image built on top of the Pytorch image from runpod is for ssh access. If ssh access isn't required then the standard vllm image can be used.

## Deploy an LLM
```sh
source .vllm-env
vllm serve microsoft/Phi-4-mini-instruct --trust-remote-code
```

Sending request
```sh
export ENDPOINT=https://fhnuir48tn4vbg-8000.proxy.runpod.net
curl ${ENDPOINT}/v1/chat/completions \                                                 
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
                "content": "Please write 500 words about the fall of Rome."
            }
        ]
    }'
```


## Speculative Decoding
Running the model with Eagle3 based speculative decoding. vLLM currently only supports Eagle3 draft models for Llama based models.
```sh
vllm serve unsloth/Meta-Llama-3.1-8B-Instruct --speculative-config '{"model": "yuhuili/EAGLE3-LLaMA3.1-Insuct-8B", "draft_tensor_parallel_size": 1, "num_speculative_tokens": 5, "method": "eagle3"}'
```

Running the model without speculative decoding
```sh
vllm serve unsloth/Meta-Llama-3.1-8B-Instruct
```

You can measure the time taken by each deployment with the following curl request. Though beware of the cache warm-up with prefix caching that is enabled by default.
```sh 
export ENDPOINT=https://xj2c6ulvnmqbk7-8080.proxy.runpod.net
curl ${ENDPOINT}/v1/chat/completions \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{
      "model": "unsloth/Meta-Llama-3.1-8B-Instruct",
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

## LoRA Serving
```sh
vllm serve Qwen/Qwen3-4B --enable-lora --lora-modules crystal-think=PinkPixel/Crystal-Think-V2 --max-lora-rank 32
```

```sh
export ENDPOINT=https://xj2c6ulvnmqbk7-8080.proxy.runpod.net
curl ${ENDPOINT}/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "crystal-think",
        "prompt": "What is Deep Learning?",
        "max_tokens": 128,
        "temperature": 0
    }' | jq
```

## Reasoning models

```sh
vllm serve Qwen/Qwen3-4B-Thinking-2507 --max-model-len 262144 --enable-reasoning --reasoning-parser deepseek_r1
```

export ENDPOINT=https://xj2c6ulvnmqbk7-8080.proxy.runpod.net
curl ${ENDPOINT}/v1/completions \
    -H "Content-Type: application/json" \
    -d '{
        "model": "Qwen/Qwen3-4B-Thinking-2507",
        "prompt": "What is Deep Learning?",
        "max_tokens": 8096,
        "temperature": 0
    }' | jq


## Multimodal Serving
```sh
vllm serve microsoft/Phi-3.5-vision-instruct --trust-remote-code --max-model-len 8192
```

```sh
export ENDPOINT=https://xj2c6ulvnmqbk7-8080.proxy.runpod.net
curl ${ENDPOINT}/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "microsoft/Phi-3.5-vision-instruct",
    "messages": [
      {
        "role": "user",
        "content": [
          { "type": "text", "text": "What’s in this image?" },
          { "type": "image_url", "image_url": { "url": "https://upload.wikimedia.org/wikipedia/commons/thumb/d/dd/Gfp-wisconsin-madison-the-nature-boardwalk.jpg/2560px-Gfp-wisconsin-madison-the-nature-boardwalk.jpg" } }
        ]
      }
    ]
  }'
```

## Running GGUF models
```sh
wget https://huggingface.co/unsloth/Phi-4-mini-instruct-GGUF/resolve/main/Phi-4-mini-instruct-Q4_K_M.gguf
```

vLLM documentation recommends using the tokenizer from base model to avoid long-time and buggy tokenizer conversion.
```sh
vllm serve ./Phi-4-mini-instruct-Q4_K_M.gguf --tokenizer microsoft/Phi-4-mini-instruct
```

```sh
export ENDPOINT=https://xj2c6ulvnmqbk7-8080.proxy.runpod.net
curl ${ENDPOINT}/v1/chat/completions \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{
      "model": "./Phi-4-mini-instruct-Q4_K_M.gguf",
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

## Batch inference
```sh
vllm run-batch \
    -i inputs.jsonl \
    -o results.jsonl \
    --model microsoft/Phi-4-mini-instruct
```

## Using tensor parallelism
```sh
vllm serve unsloth/Meta-Llama-3.1-8B-Instruct -tp 2
```

```sh 
export ENDPOINT=https://6s25orgm5ll7x1-8000.proxy.runpod.net
curl ${ENDPOINT}/v1/chat/completions \
    -X POST \
    -H 'Content-Type: application/json' \
    -d '{
      "model": "unsloth/Meta-Llama-3.1-8B-Instruct",
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

```sh
hey -n 10 -c 2 \
  -m POST \
  -H "Content-Type: application/json" \
  -d '{
    "model": "unsloth/Meta-Llama-3.1-8B-Instruct",
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

## Disaggreated serving
```sh
git clone https://github.com/vllm-project/vllm.git
cd vllm/examples/online_serving/
export HF_MODEL_NAME=unsloth/Meta-Llama-3.1-8B-Instruct
chmod +x disaggregated_prefill.sh
export VLLM_USE_V1=0
./disaggregated_prefill.sh
```


## For AMD GPUs
Use this docker image: `rocm/vllm:rocm6.4.1_vllm_0.9.1_20250715`
In the initial setup wizard for the pod, make sure to replace the docker command with `sleep infinity`

#### Models tested 
- microsoft/Phi-4-mini-instruct
- HuggingFaceTB/SmolLM3-3B
- Qwen/Qwen3-4B
- deepseek-ai/DeepSeek-R1-Distill-Qwen-7B

### GPU Tested
- A100
- A40
- H100

## Notes:
- The current docker image isn't as small as it can possibly be. No size optimizations have been done for it.
- Use `export VLLM_USE_V1=0` to switch to vLLM v0