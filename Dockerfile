# Use Python 3.11 slim image as the base
FROM python:3.11-slim

# Set working directory
WORKDIR /deps/research-rabbit

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy the project files
COPY . .

# Install dependencies and ensure console scripts are created
RUN pip install --upgrade pip && \
    pip install "langgraph-cli[inmem]==0.1.65" && \
    pip install -e . && \
    find /usr/local/bin -name "langgraph*"  # Debug: find the executable

# Create a startup script
RUN echo '#!/bin/sh\n\
export PYTHONPATH=/deps/research-rabbit\n\
export PATH=/usr/local/bin:$PATH\n\
/usr/local/bin/langgraph dev --host 0.0.0.0 --port 2024\n\
' > /start.sh && chmod +x /start.sh

# Expose the ports
EXPOSE 2024 8123

# Use the startup script
CMD ["/start.sh"]
