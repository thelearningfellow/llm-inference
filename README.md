# LLM Inference Scripts

This repo contains the instructions and scripts related to LLM inference workshop.

`slurm`: contains the instructions for running LLMs on a slurm cluster

`runpod`: contains the instructions for running LLMs on Runpod in Pods and in Serverless settings 

## vLLM Params
### Useful vLLM parameters
`--api-key`: Specify an API key required to work with the OpenAI compatible API

`--served-model-name`: Change the model name for the served model

`--port`: Port for the API server

`--pipeline-parallel-size`: Specify the pipeline parallelism degree

`--tensor-parallel-size`: Specify the tensor parallelism degree

`--enable-expert-parallel`: Enable expert parallelism for MoE


### Optimization params
RoPE settings

--max-seq-len-to-capture

--block-size

--gpu-memory-utilization

--kv-cache-dtype

--fully-sharded-loras

--max-num-batched-tokens [no default]

--max-num-seqs [no default]

--max-num-partial-prefills [1]

--max-long-partial-prefills [1]

--cuda-graph-sizes

--long-prefill-token-threshold

--enable-chunked-prefill

--limit-mm-per-prompt