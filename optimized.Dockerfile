# Optimized multi-stage Dockerfile
# Stage 1: builder uses the devel image to compile/prepare wheels
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-devel AS builder

WORKDIR /src

# Copy only requirements first to leverage layer caching
COPY app/requirements.txt ./requirements.txt

# Install minimal build deps and build wheels into /wheels, then clean apt lists
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && pip wheel --no-cache-dir --wheel-dir /wheels -r requirements.txt \
    && rm -rf /var/lib/apt/lists/*

# Copy application source after dependencies are handled (cache-friendly)
COPY app /src/app

# Stage 2: runtime uses the smaller runtime image
FROM pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime

WORKDIR /app

# Copy prepared wheels and app
COPY --from=builder /wheels /wheels
COPY --from=builder /src/app /app

# Install from wheels (no network) and then remove wheel cache
RUN pip install --no-index --no-cache-dir --find-links /wheels -r /app/requirements.txt \
    && rm -rf /wheels /root/.cache/pip

# Create non-root user for runtime security
RUN useradd -m appuser && chown -R appuser /app
USER appuser

ENV PYTHONUNBUFFERED=1
CMD ["python", "simple_app.py"]
