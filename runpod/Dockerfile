FROM runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive

# Set working directory
WORKDIR /root/home

RUN apt update && apt install openssh-server vim -y

# Create virtual environment
RUN python -m venv .vllm-venv && \
    . .vllm-venv/bin/activate && \
    pip install --upgrade pip && \
    pip install vllm==0.10.0 flashinfer-python --extra-index-url https://download.pytorch.org/whl/cu128 && \
    # Cleanup pip cache to reduce image size
    pip cache purge && \
    find /root/.cache -type d -exec rm -rf {} + || true

# Optional: Default shell to virtual environment
SHELL ["/bin/bash", "-c"]
RUN echo "source /root/home/.vllm-venv/bin/activate" >> ~/.bashrc

# Default command
CMD ["bash", "-c", "mkdir -p ~/.ssh && cd ~/.ssh && chmod 700 ~/.ssh && echo \"$PUBLIC_KEY\" >> authorized_keys && chmod 700 authorized_keys && service ssh start && sleep infinity"]
