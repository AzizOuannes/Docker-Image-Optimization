# Docker Image Optimization 

## Goal
- Reduce a large PyTorch CUDA development image (>8 GB) to a much smaller production runtime image while keeping PyTorch + CUDA functionality.

## Key results
- Baseline (`ml-baseline:latest`): 8,913,688,894 bytes (~8.91 GB)
- Optimized (`ml-optimized:latest`): 3,488,966,546 bytes (~3.49 GB)
- Savings: ~5,424,722,348 bytes (~5.42 GB) (~61% reduction)

## What I changed
- Added a multi-stage `optimized.Dockerfile` that:
  - Builds Python wheels in a `builder` stage (uses the devel image),
  - Installs only the wheels and app code in a runtime image (`-runtime`),
  - Removes apt/pip caches and runs as a non-root user.
- Kept a minimal example app in `app/simple_app.py` to validate GPU and PyTorch.

## Files in this folder
- `baseline.Dockerfile` — unoptimized reference
- `optimized.Dockerfile` — multi-stage optimized image (main deliverable)
- `.dockerignore` — reduces build context
- `app/` — example app and `requirements.txt`
- `report.tex` — LaTeX report for the assignment
- `Readme.md` — this file

## How to build (local)
1. Build baseline (optional):
```bash
docker build -f baseline.Dockerfile -t ml-baseline:latest .
```
2. Build optimized (faster when cached):
```bash
docker build -f optimized.Dockerfile -t ml-optimized:latest .
```

## How to measure sizes
- Exact byte size (authoritative):
```bash
docker image inspect ml-baseline:latest --format '{{.Size}}'
docker image inspect ml-optimized:latest --format '{{.Size}}'
```

## Quick validation (smoke tests)
```bash
docker run --gpus all --rm ml-optimized:latest python -c "import torch; print(torch.__version__, torch.cuda.is_available())"
docker run --gpus all --rm ml-optimized:latest python -c "import torch; m=torch.nn.Linear(3,2).cuda(); print(m(torch.randn(1,3).cuda()))"
```

## Trade-offs
- The optimized runtime omits compilers, dev headers, and profiling tools to save space. Keep a `debug` image (builder stage) for troubleshooting if needed.



