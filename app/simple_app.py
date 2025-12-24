import torch
import time


def main():
    print("PyTorch version:", torch.__version__)
    print("CUDA available:", torch.cuda.is_available())

    # Simple CPU fallback test and small tensor operation
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    x = torch.randn(3, 3, device=device)
    w = torch.randn(3, 3, device=device)
    y = torch.matmul(x, w)
    print("Computation result shape:", y.shape)

    # Small model inference example
    model = torch.nn.Sequential(
        torch.nn.Linear(3, 16),
        torch.nn.ReLU(),
        torch.nn.Linear(16, 2)
    ).to(device)

    with torch.no_grad():
        out = model(torch.randn(1, 3, device=device))
    print("Model output:", out)


if __name__ == '__main__':
    main()
