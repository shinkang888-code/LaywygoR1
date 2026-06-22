# 로이고 R1 지식 증류 파이프라인

Gemini(교사) Q&A → 검수 → JSONL → LoRA 학습 → 로이고 R1(학생) 배포

## 아키텍처

```
[LawyGo 사용자 질의]
        ↓
[Gemini API] ──성공 응답──→ ai_distillation_samples (Supabase)
        ↓                           ↓
   실시간 답변              관리자 검수 (승인/거절)
                                    ↓
                          JSONL 보내기 (DeepSeek-R1 형식)
                                    ↓
                          GPU 서버 LoRA SFT (distill-lora-train.sh)
                                    ↓
                          vLLM에 병합·배포 → 로이고 R1 강화
```

## 1. 데이터 수집 (자동)

- `관리자 > 지식 증류`에서 **수집 활성화** (기본 ON)
- Gemini·ChatGPT 성공 응답이 `ai_distillation_samples`에 저장됩니다
- 최소 길이 필터(기본: 질문 30자, 답변 80자)로 노이즈 제거

## 2. 검수·승인

- `pending` → 관리자가 **승인** → `approved`
- 품질 낮은 샘플은 **거절**

## 3. JSONL 보내기

관리자 UI **「학습 데이터 보내기」** 또는 CLI:

```bash
npm run export:distillation
```

형식 (DeepSeek-R1 권장 — system은 user에 병합):

```json
{"messages":[{"role":"user","content":"시스템지시\n\n---\n\n질문"},{"role":"assistant","content":"`추론`\n\n답변"}]}
```

## 4. LoRA 학습 (GPU 서버)

```bash
pip install torch transformers peft trl datasets accelerate

export BASE_MODEL=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
export TRAIN_FILE=./exports/roygo-r1-export.jsonl
export OUTPUT_DIR=./checkpoints/roygo-r1-lora

chmod +x services/deepseek-r1/distill-lora-train.sh
./services/deepseek-r1/distill-lora-train.sh
```

## 5. 배포

학습된 LoRA를 vLLM에 로드하거나 병합 후 `DEEPSEEK_MODEL` 경로를 갱신합니다.

## 법적·운영 주의

- Gemini 응답의 **저작권·이용약관** 준수 (Google AI Terms)
- 개인정보·비밀 사건 정보는 검수 단계에서 **거절**
- 증류는 **지속 루프**: 배포 후에도 Gemini 교사 데이터를 계속 축적

## 관련 경로

| 경로 | 설명 |
|------|------|
| `supabase/migrations/20260628000000_ai_distillation.sql` | DB 스키마 |
| `src/lib/aiDistillation/` | 수집·보내기 로직 |
| `/admin/settings/ai-distillation` | 관리 UI |
| `scripts/export-distillation-dataset.mjs` | CLI 보내기 |
