# Homelab gfx1151 base: ROCm 7.2.1 + PyTorch 2.9.1 with PYTORCH_ROCM_ARCH=gfx1151
FROM homelab/rocm7-gfx1151:stablenightly

LABEL org.opencontainers.image.source=https://github.com/beecave-homelab/insanely-fast-whisper-rocm

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    TZ=Europe/Amsterdam \
    ROCM_PATH=/opt/rocm \
    PYTORCH_ROCM_ARCH=gfx1151 \
    HIP_VISIBLE_DEVICES=0 \
    GRADIO_SERVER_NAME=0.0.0.0

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ffmpeg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

COPY requirements-rocm-v7-2.txt .
COPY .python-version .

# Keep the base image's ROCm PyTorch; this requirements file does not pin torch.
RUN python -m pip install --no-cache-dir -r requirements-rocm-v7-2.txt

COPY openapi.yaml /app/
COPY pyproject.toml /app/
COPY ./insanely_fast_whisper_rocm /app/insanely_fast_whisper_rocm/

RUN python -m pip install --no-cache-dir --no-deps .

EXPOSE 8888
EXPOSE 7860

CMD ["insanely-fast-whisper-rocm"]
