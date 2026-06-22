# filepath: services/deepseek-r1/serve-windows.ps1
# Windows 로컬 GPU 서버 (Ollama + DeepSeek-R1 7B)
# RTX 4060 Ti 8GB 권장 모델: deepseek-r1:7b
param(
  [string]$Model = $env:DEEPSEEK_MODEL,
  [int]$Port = 11434
)

$ErrorActionPreference = "Stop"
if (-not $Model) { $Model = "deepseek-r1:7b" }

function Find-Ollama {
  $candidates = @(
    "$env:LOCALAPPDATA\Programs\Ollama\ollama.exe",
    "$env:ProgramFiles\Ollama\ollama.exe"
  )
  foreach ($p in $candidates) {
    if (Test-Path $p) { return $p }
  }
  $cmd = Get-Command ollama -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

$ollama = Find-Ollama
if (-not $ollama) {
  Write-Host "Ollama가 설치되어 있지 않습니다." -ForegroundColor Red
  Write-Host "  npm run gpu:install"
  exit 1
}

Write-Host "Ollama: $ollama"
Write-Host "모델: $Model"

# 백그라운드 서비스(Ollama app)가 없으면 serve
try {
  $null = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/api/tags" -TimeoutSec 3
  Write-Host "Ollama API 이미 실행 중 (포트 $Port)"
} catch {
  Write-Host "Ollama 서버 시작 중..."
  Start-Process -FilePath $ollama -ArgumentList "serve" -WindowStyle Hidden
  $deadline = (Get-Date).AddMinutes(2)
  while ((Get-Date) -lt $deadline) {
    try {
      $null = Invoke-RestMethod -Uri "http://127.0.0.1:$Port/api/tags" -TimeoutSec 2
      break
    } catch {
      Start-Sleep -Seconds 2
    }
  }
}

Write-Host "모델 다운로드/확인: $Model (최초 1회 수 GB, 시간 소요)"
& $ollama pull $Model
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "로이고 AI GPU 서버 준비 완료" -ForegroundColor Green
Write-Host "  API: http://127.0.0.1:$Port/v1"
Write-Host "  모델: $Model"
Write-Host "  테스트: npm run gpu:test"
