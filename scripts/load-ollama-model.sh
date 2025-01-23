#!/usr/bin/env bash

echo "Waiting for Ollama to be ready..."
sleep 10
curl -X POST http://localhost:11434/api/pull \
  -H "Content-Type: application/json" \
  -d '{"name": "deepseek-r1:14b", "options": {"num_gpu": 2}}'
