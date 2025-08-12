#!/bin/bash --login
#
#SBATCH --job-name=batch_inference_job
#SBATCH --output=%x-%j.out
#SBATCH --error=%x-%j.err
#
#SBATCH --time=01:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32GB
#SBATCH --gres=gpu:a100:1
#SBATCH --reservation=interactive

set -e # stop bash script on first error

mamba activate vllm-env
export HF_HOME=~/.cache/huggingface
export VLLM_LOGGING_LEVEL=DEBUG

# Optionally add "$@" to pass additional arguments to the script
vllm run-batch "$@"