# Baseline Dockerfile

FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-devel

WORKDIR /app

# Copy application
COPY app /app

# Install dependencies (no wheel caching, leave apt caches)
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential git libsndfile1 \
    && pip install --no-cache-dir -r requirements.txt

ENV PYTHONUNBUFFERED=1

CMD ["python", "simple_app.py"]
