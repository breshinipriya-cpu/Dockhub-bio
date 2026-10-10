# Use official lightweight Python image
FROM python:3.11-slim

# Set non-interactive mode for apt and prevent Python from buffering stdout/stderr
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install OpenBabel and system utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    openbabel \
    curl \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install official AutoDock Vina Linux 64-bit binary
RUN wget -q https://github.com/ccsb-scripps/AutoDock-Vina/releases/download/v1.2.5/vina_1.2.5_linux_x86_64 -O /usr/local/bin/vina \
    && chmod +x /usr/local/bin/vina

# Set work directory
WORKDIR /app

# Install Python requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application code
COPY . .

# Render exposes PORT dynamically (defaults to 10000)
ENV PORT=10000
EXPOSE 10000

# Start Uvicorn bound to 0.0.0.0 and dynamically assigned $PORT
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-10000}"]
