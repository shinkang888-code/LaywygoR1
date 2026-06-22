# 로이고 R1 — DeepSeek-R1 자체 호스팅

LawyGo의 **로이고 R1** 프로바이더는 OpenAI 호환 API를 사용합니다.

## Windows (RTX 4060 Ti 8GB 등) — Ollama 권장

32B는 VRAM 8GB에 맞지 않습니다. **deepseek-r1:7b** 를 사용하세요.

```powershell
npm run gpu:install   # Ollama + .env.local
npm run gpu:start       # 모델 pull + API :11434
npm run gpu:test        # 연결 테스트
```

수동:

```powershell
powershell -ExecutionPolicy Bypass -File services/deepseek-r1/serve-windows.ps1
```

`.env.local`:

```env
DEEPSEEK_API_BASE_URL=http://127.0.0.1:11434/v1
DEEPSEEK_API_KEY=lawygo-local-gpu
DEEPSEEK_MODEL=deepseek-r1:7b
```

## Linux GPU — vLLM

```bash
pip install vllm

# 32B (2× GPU 권장)
export DEEPSEEK_MODEL=deepseek-ai/DeepSeek-R1-Distill-Qwen-32B
export TENSOR_PARALLEL_SIZE=2
chmod +x services/deepseek-r1/serve.sh
./services/deepseek-r1/serve.sh
```

개발/테스트용 7B:

```bash
export DEEPSEEK_MODEL=deepseek-ai/DeepSeek-R1-Distill-Qwen-7B
export TENSOR_PARALLEL_SIZE=1
./services/deepseek-r1/serve.sh
```

## 2. curl 연결 테스트

```bash
npm run test:deepseek-vllm
# 또는
DEEPSEEK_API_BASE_URL=http://127.0.0.1:8000/v1 \
DEEPSEEK_API_KEY=your-token \
node scripts/test-deepseek-vllm.mjs
```

## 3. LawyGo 환경 변수

```env
DEEPSEEK_API_BASE_URL=https://your-gpu-host/v1
DEEPSEEK_API_KEY=your-bearer-token
DEEPSEEK_MODEL=deepseek-ai/DeepSeek-R1-Distill-Qwen-32B
```

관리자 > AI 연동관리에서도 동일 값을 DB에 저장할 수 있습니다.

## 보안 (Render 게이트웨이 권장)

Render에는 GPU가 없습니다. **lawygo-ai-gateway** 로 Vercel ↔ GPU 사이에 HTTPS·Bearer 프록시를 두세요.

```bash
npm run deploy:lawygo-ai
# Render Dashboard → LAWYGO_AI_UPSTREAM_URL=https://your-gpu/v1
```

- GPU API 앞단에 Bearer 토큰 인증을 반드시 설정하세요.
- Vercel(프론트) → Render 게이트웨이만 공개 URL로 노출 (GPU URL은 Render env에만 저장).

자세한 내용: `services/lawygo-ai-gateway/README.md`

## 라이선스

DeepSeek-R1 MIT. Distill 모델은 Qwen/Llama 베이스 라이선스도 준수하세요.
