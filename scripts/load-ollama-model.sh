#!/usr/bin/env bash

MAX_RETRIES=30
RETRY_INTERVAL=2

echo "Waiting for Ollama to be ready..."
for i in $(seq 1 $MAX_RETRIES); do
  if curl -s --max-time 2 http://localhost:11434/api/version > /dev/null; then
    echo "Ollama is ready"
    break
  fi
  
  if [ $i -eq $MAX_RETRIES ]; then
    echo "Timeout waiting for Ollama"
    exit 1
  fi
  
  echo "Attempt $i failed, retrying in ${RETRY_INTERVAL}s..."
  sleep $RETRY_INTERVAL
done

# Only proceed with model loading if Ollama is ready
curl -X POST http://localhost:11434/api/pull \
  -H "Content-Type: application/json" \
  -d '{
    "name": "deepseek-r1:14b",
    "options": {
      "num_gpu": 1,
      "gpu_memory_utilization": 0.9,
      "f16": true,
      "disable_cpu": true,
      "gpu_layers": -1
    }
  }'
