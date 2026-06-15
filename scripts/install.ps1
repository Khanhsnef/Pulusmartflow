# PuluSmartFlow — Installer for Windows PowerShell
# Run: Set-ExecutionPolicy Bypass -Scope Process; .\scripts\install.ps1

Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🤖 PuluSmartFlow — Windows Installer ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════╝`n" -ForegroundColor Cyan

# ─── Bước 1: Kiểm tra Python, Node.js, Claude Code và 9Router ───
Write-Host "[1/6] Kiểm tra các công cụ nền tảng..." -ForegroundColor Yellow

# Python & httpx
$pythonCheck = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCheck) {
    Write-Host "❌ Không tìm thấy Python! Vui lòng cài đặt Python và tích hợp vào PATH." -ForegroundColor Red
    Exit
}
try {
    & python -c "import httpx" 2>$null
} catch {
    Write-Host "   Đang cài thư viện Python httpx..." -ForegroundColor Yellow
    & pip install httpx --quiet
}
Write-Host "   Python & httpx OK" -ForegroundColor Green

# Node.js & npm
$npmCheck = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmCheck) {
    Write-Host "❌ Không tìm thấy Node.js & npm! Vui lòng cài đặt từ: https://nodejs.org" -ForegroundColor Red
    Exit
}
Write-Host "   Node.js & npm OK" -ForegroundColor Green

# Claude Code CLI
$claudeCheck = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCheck) {
    Write-Host "   Đang cài đặt Claude Code CLI (@anthropic-ai/claude-code)..." -ForegroundColor Yellow
    & npm install -g @anthropic-ai/claude-code
}
Write-Host "   Claude Code CLI OK" -ForegroundColor Green

# 9Router
$routerCheck = Get-Command 9router -ErrorAction SilentlyContinue
if (-not $routerCheck) {
    Write-Host "   Đang cài đặt 9Router..." -ForegroundColor Yellow
    & npm install -g 9router
}
Write-Host "   9Router OK" -ForegroundColor Green
Write-Host "✅ Các công cụ nền tảng đã sẵn sàng!" -ForegroundColor Green

# ─── Bước 2: Cài AI Classifier ───
Write-Host "[2/6] Cài AI Classifier..." -ForegroundColor Yellow
$localBin = "$HOME\.local\bin"
if (-not (Test-Path $localBin)) {
    New-Item -Path $localBin -ItemType Directory -Force | Out-Null
}

$scriptDir = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
$scriptDir = Split-Path -Path $scriptDir -Parent # Get root dir

Copy-Item -Path "$scriptDir\ai-classify.py" -Destination "$localBin\ai-classify.py" -Force
Write-Host "✅ ai-classify.py → $localBin\" -ForegroundColor Green

# ─── Bước 3: Thêm Smart Router vào PowerShell Profile ───
Write-Host "[3/6] Cài Smart Router vào PowerShell Profile..." -ForegroundColor Yellow

$profilePath = $PROFILE
$profileDir = Split-Path -Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force | Out-Null
}

$snippet = Get-Content -Path "$scriptDir\templates\powershell-profile.ps1" -Raw
$currentProfile = Get-Content -Path $profilePath -Raw

if ($currentProfile -match "SMART AI ROUTER") {
    Write-Host "   ⚠️  Smart Router đã tồn tại trong Profile. Bỏ qua để tránh trùng lặp." -ForegroundColor Yellow
} else {
    # Backup profile first
    if (Test-Path $profilePath) {
        Copy-Item -Path $profilePath -Destination "$profilePath.bak" -Force
        Write-Host "   💾 Đã sao lưu Profile tại: $profilePath.bak" -ForegroundColor Gray
    }
    
    # Hỏi API Key
    Write-Host ""
    $userKey = Read-Host "🔑 Nhập API Key 9Router của bạn (nhấn Enter để bỏ qua và tự điền sau)"
    if ($userKey) {
        $configDir = "$HOME\.config\pulu"
        if (-not (Test-Path $configDir)) {
            New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        }
        $envContent = @"
# Configuration env for 9Router and PuluSmartFlow
export ANTHROPIC_BASE_URL="http://127.0.0.1:8787/v1"
export ANTHROPIC_API_KEY="$userKey"
"@
        Set-Content -Path "$configDir\env" -Value $envContent
        Write-Host "   ✅ Đã cấu hình và lưu API Key bảo mật tại $configDir\env" -ForegroundColor Green
    }
    
    Add-Content -Path $profilePath -Value "`n$snippet"
    Write-Host "✅ Smart Router đã thêm vào PowerShell Profile ($profilePath)" -ForegroundColor Green
}

# ─── Bước 4: Tạo cấu trúc workspace ───
Write-Host "[4/6] Tạo cấu trúc workspace..." -ForegroundColor Yellow
$workspace = "$HOME\Desktop\SmartFlowWorkspace"
$agentDir = "$workspace\.claude\agents"
$outDir = "$workspace\output"

if (-not (Test-Path $agentDir)) { New-Item -Path $agentDir -ItemType Directory -Force | Out-Null }
if (-not (Test-Path $outDir)) { New-Item -Path $outDir -ItemType Directory -Force | Out-Null }

# Copy agent templates
Copy-Item -Path "$scriptDir\agents\*" -Destination $agentDir -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$scriptDir\templates\CLAUDE.md" -Destination "$workspace\CLAUDE.md" -Force -ErrorAction SilentlyContinue
Copy-Item -Path "$scriptDir\templates\AGENTS.md" -Destination "$workspace\AGENTS.md" -Force -ErrorAction SilentlyContinue

Write-Host "✅ Workspace tạo tại: $workspace" -ForegroundColor Green

# ─── Bước 5: Cấu hình tối ưu Token & MCP ───
Write-Host "[5/6] Tối ưu hóa cấu hình Claude Code (Token limits, Prompt cache, MCPs)..." -ForegroundColor Yellow
& python "$scriptDir\scripts\optimize_claude_config.py"
Write-Host "✅ Claude Code Config OK" -ForegroundColor Green

# ─── Bước 6: Hướng dẫn tiếp theo ───
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  ✅ Cài đặt hoàn tất!                            ║" -ForegroundColor Cyan
Write-Host "╠═══════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  📌 Bước cuối cần làm thủ công:                  ║" -ForegroundColor Cyan
Write-Host "║                                                   ║" -ForegroundColor Cyan
Write-Host "║  1. Chỉnh API Key trong File Profile của bạn:     ║" -ForegroundColor Cyan
Write-Host "║     Gõ lệnh: notepad `$PROFILE                    ║" -ForegroundColor Cyan
Write-Host "║     Đặt biến: `$env:ANTHROPIC_API_KEY = `"key`"     ║" -ForegroundColor Cyan
Write-Host "║                                                   ║" -ForegroundColor Cyan
Write-Host "║  2. Reload shell:                                 ║" -ForegroundColor Cyan
Write-Host "║     Tắt đi bật lại Terminal hoặc chạy:            ║" -ForegroundColor Cyan
Write-Host "║     . `$PROFILE                                   ║" -ForegroundColor Cyan
Write-Host "║                                                   ║" -ForegroundColor Cyan
Write-Host "║  3. Bắt đầu dùng:                                ║" -ForegroundColor Cyan
Write-Host "║     chat                                         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════╝" -ForegroundColor Cyan
