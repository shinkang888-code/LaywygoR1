#!/usr/bin/env bash
# filepath: services/deepseek-r1/serve.sh
# DeepSeek-R1-Distill vLLM 서버 (OpenAI 호환 API)
# 사용: chmod +x serve.sh && ./serve.sh
set -euo pipefail

MODEL="${DEEPSEEK_MODEL:-deepseek-ai/DeepSeek-R1-Distill-Qwen-32B}"
PORT="${PORT:-8000}"
TP="${TENSOR_PARALLEL_SIZE:-2}"
MAX_LEN="${MAX_MODEL_LEN:-32768}"

echo "Starting vLLM: $MODEL on 0.0.0.0:$PORT (tp=$TP)"

exec vllm serve "$MODEL" \
  --host 0.0.0.0 \
  --port "$PORT" \
  --tensor-parallel-size "$TP" \
  --max-model-len "$MAX_LEN" \
  --enforce-eager
