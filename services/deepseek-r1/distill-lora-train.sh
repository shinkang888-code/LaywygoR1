#!/usr/bin/env bash
# filepath: services/deepseek-r1/distill-lora-train.sh
# 로이고 R1 지식 증류 LoRA SFT (GPU 서버에서 실행)
set -euo pipefail

BASE_MODEL="${BASE_MODEL:-deepseek-ai/DeepSeek-R1-Distill-Qwen-7B}"
TRAIN_FILE="${TRAIN_FILE:-./exports/roygo-r1-export.jsonl}"
OUTPUT_DIR="${OUTPUT_DIR:-./checkpoints/roygo-r1-lora}"
EPOCHS="${EPOCHS:-2}"
BATCH_SIZE="${BATCH_SIZE:-1}"
LR="${LR:-2e-5}"
MAX_SEQ_LEN="${MAX_SEQ_LEN:-4096}"

if [[ ! -f "$TRAIN_FILE" ]]; then
  echo "학습 파일 없음: $TRAIN_FILE"
  echo "관리자 > 지식 증류에서 JSONL을 보내거나 npm run export:distillation 실행"
  exit 1
fi

echo "Base: $BASE_MODEL"
echo "Train: $TRAIN_FILE"
echo "Out: $OUTPUT_DIR"

python3 "$(dirname "$0")/distill-lora-train.py" \
  --base_model "$BASE_MODEL" \
  --train_file "$TRAIN_FILE" \
  --output_dir "$OUTPUT_DIR" \
  --num_train_epochs "$EPOCHS" \
  --per_device_train_batch_size "$BATCH_SIZE" \
  --learning_rate "$LR" \
  --max_seq_length "$MAX_SEQ_LEN"

echo "완료. vLLM 배포 시 LoRA 어댑터 경로: $OUTPUT_DIR"
