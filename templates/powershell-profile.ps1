# === SMART AI ROUTER v3 (LLM Intent Classifier + Regex Fallback) ===
# Thêm đoạn này vào file Profile của PowerShell ($PROFILE)
# Để mở và sửa Profile: notepad $PROFILE

# --- Cấu hình 9Router ---
$env:ANTHROPIC_BASE_URL = "http://127.0.0.1:8787/v1"
$env:ANTHROPIC_API_KEY = "your-9router-api-key-here"   # ← Thay bằng key của bạn
# --------------------------

# --- Mapping intent → model ---
function Get-IntentModel {
    param([string]$intent)
    switch ($intent) {
        "DEEP_THINK"  { return @("cc/claude-opus-4-8", "🧠 OPUS 4.8 (AI-routed)") }
        "CODE_FORMAT" { return @("cc/claude-sonnet-4-6", "💻 SONNET (AI-routed)") }
        "LANGUAGE"    { return @("gc/gemini-3-pro-preview", "⚡ GEMINI PRO (AI-routed)") }
        "ENGLISH"     { return @("oc/gpt-5-5", "🌐 GPT-5.5 (AI-routed)") }
        "QUICK"       { return @("oc/deepseek-v4-flash-free", "💨 DEEPSEEK (AI-routed)") }
        default       { return $null }
    }
}

# --- Regex fallback (không cần API) ---
function Get-RegexRoute {
    param([string]$prompt)
    $lower = $prompt.ToLower()
    
    if ($lower -match '(phân tích|chiến lược|kế hoạch|logic|kiến trúc|hệ thống|quy hoạch|tư duy|chiều sâu|đánh đổi|trade-off|p\&l|sla|nguyên nhân gốc rễ|root cause|insight|quyết định|decision|rủi ro|fraud|cung cầu|supply|demand|tâm lý|hành vi|okr|kpi|benchmark|retention|churn)') {
        return @("cc/claude-opus-4-8", "🧠 OPUS 4.8 (regex)")
    }
    elseif ($lower -match '(english|tiếng anh|proposal|hq|headquarter|leadership|international|global|board|presentation|investor|deck|pitch|official|formal|write in english|draft in english)') {
        return @("oc/gpt-5-5", "🌐 GPT-5.5 (regex)")
    }
    elseif ($lower -match '(dịch thuật|dịch|thông báo|zalo|chính tả|ngữ pháp|viết lại|caption|kịch bản|nội dung|tóm tắt|đọc file|log|competitive|cạnh tranh|grab|be |xanhsm)') {
        return @("gc/gemini-3-pro-preview", "⚡ GEMINI PRO (regex)")
    }
    elseif ($lower -match '(hỏi nhanh|giải thích|tính toán|định nghĩa|là gì|như thế nào|thế nào|regex|quick|nhanh)') {
        return @("oc/deepseek-v4-flash-free", "💨 DEEPSEEK (regex)")
    }
    elseif ($lower -match '(trình bày|code|lập trình|html|css|giao diện|ui|ux|lark|docs|báo cáo|định dạng|table|bảng|markdown|website|landing page|sql|query|dashboard)') {
        return @("cc/claude-sonnet-4-6", "💻 SONNET (regex)")
    }
    else {
        return @("cc/claude-opus-4-8", "🧠 OPUS 4.8 (default)")
    }
}

# --- One-shot AI: ai "câu hỏi" ---
function Invoke-SmartClaude {
    param([string]$prompt)
    if ([string]::IsNullOrEmpty($prompt)) {
        Write-Host "⚠️  Ví dụ: ai `"phân tích chiến lược Q3`"" -ForegroundColor Yellow
        return
    }

    $pyPath = "$HOME\.local\bin\ai-classify.py"
    $intent = ""
    if (Test-Path $pyPath) {
        $intent = & python $pyPath $prompt 2>$null
        if ($intent) { $intent = $intent.Trim() }
    }

    $route = Get-IntentModel $intent
    if ($null -eq $route) {
        $route = Get-RegexRoute $prompt
    }

    $model = $route[0]
    $label = $route[1]

    Write-Host "`n[$label] -> 🚀 Đang xử lý..." -ForegroundColor Cyan
    claude --model $model -p $prompt
}
Set-Alias -Name ai -Value Invoke-SmartClaude

# --- Claude aliases ---
function c-opus { claude --model cc/claude-opus-4-8 $args }
function c-think { claude --model ag/claude-opus-4-6-thinking $args }
function c-sonnet { claude --model cc/claude-sonnet-4-6 $args }
function c-gemini { claude --model gc/gemini-3-pro-preview $args }
function c-gpt { claude --model cx/gpt-5.5 $args }
function c-fast { claude --model oc/deepseek-v4-flash-free $args }

# --- Detect model (cho smart chat và command_not_found) ---
function Get-DetectModel {
    param([string]$inputStr)
    
    $pyPath = "$HOME\.local\bin\ai-classify.py"
    $intent = ""
    if (Test-Path $pyPath) {
        $intent = & python $pyPath $inputStr 2>$null
        if ($intent) { $intent = $intent.Trim() }
    }
    
    $route = Get-IntentModel $intent
    if ($null -ne $route) {
        $model = $route[0]
        $label = $route[1]
        
        if ($intent -eq "CODE_FORMAT") {
            $lower = $inputStr.ToLower()
            if ($lower -match '(docx|pdf|xuất|tạo.*file|convert|export|ghi|lưu file)') {
                return @($model, $label, "TOOL")
            }
        }
        return @($model, $label, "TEXT")
    }
    
    # Fallback Regex
    $lower = $inputStr.ToLower()
    if ($lower -match '(phân tích|chiến lược|kế hoạch|insight|quyết định|rủi ro|fraud|cung cầu|supply|demand|tâm lý|hành vi|sla|root cause|nguyên nhân|okr|kpi|benchmark|retention|churn|ltv)') {
        return @("cc/claude-opus-4-8", "🧠 OPUS 4.8", "TEXT")
    }
    elseif ($lower -match '(english|tiếng anh|proposal|hq|leadership|global|board|investor|international|official|formal)') {
        return @("oc/gpt-5-5", "🌐 GPT-5.5", "TEXT")
    }
    elseif ($lower -match '(thông báo|zalo|viết lại|caption|kịch bản|nội dung|tóm tắt|dịch|cạnh tranh|grab|be |xanhsm|competitive)') {
        return @("gc/gemini-3-pro-preview", "⚡ GEMINI PRO", "TEXT")
    }
    elseif ($lower -match '(hỏi nhanh|định nghĩa|là gì|nhanh|quick|regex|tính toán|giải thích)') {
        return @("oc/deepseek-v4-flash-free", "💨 DEEPSEEK", "TEXT")
    }
    elseif ($lower -match '(docx|pdf|xuất|tạo.*file|định dạng|chuyển đổi|convert|export|ghi|lưu file)') {
        return @("cc/claude-sonnet-4-6", "💻 SONNET", "TOOL")
    }
    elseif ($lower -match '(sql|query|html|code|dashboard|báo cáo|lark|markdown|lập trình|script|file)') {
        return @("cc/claude-sonnet-4-6", "💻 SONNET", "TEXT")
    }
    else {
        return @("cc/claude-opus-4-8", "🤖 OPUS 4.8", "TEXT")
    }
}

# --- Smart Chat REPL ---
function Invoke-SmartChat {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  🤖 Smart Chat — tự động routing model  ║" -ForegroundColor Green
    Write-Host "║  Gõ 'exit' hoặc Ctrl+C để thoát         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    $first_msg = $true
    while ($true) {
        $inputVal = Read-Host "You ▶"
        if ($null -eq $inputVal) { continue }
        $inputVal = $inputVal.Trim()
        
        if ([string]::IsNullOrEmpty($inputVal)) { continue }
        if ($inputVal -match '^(exit|quit|bye|thoát|q)$') {
            Write-Host "👋 Tạm biệt!" -ForegroundColor Yellow
            break
        }

        $detect = Get-DetectModel $inputVal
        $model = $detect[0]
        $label = $detect[1]
        $mode = $detect[2]

        Write-Host "`n$label`n" -ForegroundColor Yellow

        if ($mode -eq "TOOL") {
            Write-Host "🔧 Tool Mode — gõ /exit sau khi xong để quay lại đây" -ForegroundColor DarkGray
            if ($first_msg) {
                claude --model $model --dangerously-skip-permissions $inputVal
                $first_msg = $false
            } else {
                claude --model $model --dangerously-skip-permissions --continue $inputVal
            }
        } else {
            if ($first_msg) {
                claude --model $model -p $inputVal
                $first_msg = $false
            } else {
                claude --model $model --continue -p $inputVal
            }
        }
        Write-Host ""
    }
}
Set-Alias -Name chat -Value Invoke-SmartChat
Set-Alias -Name start -Value Invoke-SmartChat

# --- Command Not Found → Auto-route to AI (Chỉ áp dụng trong PowerShell 3.0+) ---
$ExecutionContext.SessionState.InvokeCommand.CommandNotFoundAction = {
    param($commandName, $commandLookupEventArgs)
    
    $inputVal = $commandName
    $detect = Get-DetectModel $inputVal
    $model = $detect[0]
    $label = $detect[1]
    
    Write-Host "`n$label (Auto-routed)`n" -ForegroundColor Yellow
    claude --model $model --continue -p $inputVal
    
    # Dừng tìm kiếm lệnh để ngăn báo lỗi màu đỏ của PowerShell
    $commandLookupEventArgs.StopSearch = $true
}
# ============================================
