# LaywygoR1 — LawyGo AI 레퍼런스 저장소

이 저장소는 **DeepSeek-R1 공식 문서**와 **LawyGo 로이고 R1 인프라·학습 스크립트**를 함께 보관합니다.

실제 애플리케이션 코드는 [`lawygo_make`](https://github.com/shinkang888-code/lawygo_make) (베타) / `lawygo` (프로덕션)에 있습니다.

## 디렉터리

| 경로 | 설명 |
|------|------|
| `README.md` | DeepSeek-R1 공식 문서 (upstream) |
| `services/deepseek-r1/` | Ollama/vLLM 실행·LoRA 증류 스크립트 |
| `services/deepseek-r1/distill/` | Gemini → R1 지식 증류 파이프라인 가이드 |

## LawyGo 연동 아키텍처

```
[Gemini 교사] ──법률백과·AI Q&A──→ ai_distillation_samples
        ↓                                    ↓
   실시간 답변 (메인)                  관리자 검수 → JSONL
        ↓                                    ↓
[로이고 R1 보조] ← RAG(pgvector) ← legal_vectors ingest
        ↓                                    ↓
   LoRA SFT (7B 로컬 / 32B GPU) ← distill-lora-train.sh
```

## 빠른 시작 (Windows 8GB VRAM)

```powershell
# lawygo_make 프로젝트에서
npm run gpu:install
npm run gpu:start
npm run gpu:test
```

환경 변수 (`.env.local`):

```env
DEEPSEEK_API_BASE_URL=http://127.0.0.1:11434/v1
DEEPSEEK_API_KEY=lawygo-local-gpu
DEEPSEEK_MODEL=deepseek-r1:7b
OPENAI_API_KEY=sk-...   # pgvector embedding (선택)
```

## 학습 루프

1. **백과 ingest** — 판례·법령·PDF → `legal_vectors` (+ OpenAI embedding)
2. **Gemini 메인** — 법률백과 검색·모범답안 (증류 샘플 자동 수집)
3. **R1 RAG 보조** — UI에서 「로이고 R1 (RAG 보조)」 선택 시 검색 컨텍스트 주입
4. **검수·export** — `npm run export:distillation` / `export:encyclopedia-distillation`
5. **LoRA** — `services/deepseek-r1/distill-lora-train.sh`
6. **CI** — `.github/workflows/lora-distillation.yml` (lawygo_make)

## 32B 프로덕션

8GB VRAM에는 `deepseek-r1:7b`만 가능합니다. 32B는 Linux GPU 2장+ 또는 클라우드 GPU에서 vLLM으로 호스팅하고 Render `lawygo-ai-gateway`로 Vercel과 연결하세요.

자세한 내용: `services/deepseek-r1/README.md`
