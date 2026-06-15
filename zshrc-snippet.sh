
# === SMART AI ROUTER v3 (LLM Intent Classifier + Regex Fallback) ===
# Thêm đoạn này vào cuối file ~/.zshrc
# Sau đó chạy: source ~/.zshrc

# --- Cấu hình 9Router ---
export ANTHROPIC_BASE_URL="http://127.0.0.1:8787/v1"
export ANTHROPIC_API_KEY="your-9router-api-key-here"   # ← Thay bằng key của bạn
# --------------------------

# --- Mapping intent → model ---
_intent_to_model() {
    local intent="$1"
    case "$intent" in
        DEEP_THINK)  echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (AI-routed)" ;;
        CODE_FORMAT) echo "cc/claude-sonnet-4-6|💻 SONNET (AI-routed)" ;;
        LANGUAGE)    echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO (AI-routed)" ;;
        ENGLISH)     echo "oc/gpt-5-5|🌐 GPT-5.5 (AI-routed)" ;;
        QUICK)       echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK (AI-routed)" ;;
        *)           echo "" ;;
    esac
}

# --- Regex fallback (không cần API) ---
_regex_route() {
    local lower=$(echo "$1" | awk '{print tolower($0)}')
    if [[ "$lower" =~ (phân tích|chiến lược|kế hoạch|logic|kiến trúc|hệ thống|quy hoạch|tư duy|chiều sâu|đánh đổi|trade-off|p\&l|sla|nguyên nhân gốc rễ|root cause|insight|quyết định|decision|rủi ro|fraud|cung cầu|supply|demand|tâm lý|hành vi|okr|kpi|benchmark|retention|churn) ]]; then
        echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (regex)"
    elif [[ "$lower" =~ (english|tiếng anh|proposal|hq|headquarter|leadership|international|global|board|presentation|investor|deck|pitch|official|formal|write in english|draft in english) ]]; then
        echo "oc/gpt-5-5|🌐 GPT-5.5 (regex)"
    elif [[ "$lower" =~ (dịch thuật|dịch|thông báo|zalo|chính tả|ngữ pháp|viết lại|caption|kịch bản|nội dung|tóm tắt|đọc file|log|competitive|cạnh tranh|grab|be |xanhsm) ]]; then
        echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO (regex)"
    elif [[ "$lower" =~ (hỏi nhanh|giải thích|tính toán|định nghĩa|là gì|như thế nào|thế nào|regex|quick|nhanh) ]]; then
        echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK (regex)"
    elif [[ "$lower" =~ (trình bày|code|lập trình|html|css|giao diện|ui|ux|lark|docs|báo cáo|định dạng|table|bảng|markdown|website|landing page|sql|query|dashboard) ]]; then
        echo "cc/claude-sonnet-4-6|💻 SONNET (regex)"
    else
        echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (default)"
    fi
}

# --- One-shot AI: ai "câu hỏi" ---
smart_claude() {
    local prompt="$*"
    if [[ -z "$prompt" ]]; then
        echo "⚠️  Ví dụ: ai \"phân tích chiến lược Q3\""
        return 1
    fi

    local result=""
    local intent=$(python3 ~/.local/bin/ai-classify.py "$prompt" 2>/dev/null)
    result=$(_intent_to_model "$intent")

    if [[ -z "$result" ]]; then
        result=$(_regex_route "$prompt")
    fi

    local model="${result%%|*}"
    local label="${result#*|}"
    echo -e "\n[$label] -> 🚀 Đang xử lý..."
    claude --model "$model" -p "$prompt"
}
alias ai="smart_claude"

# --- Claude aliases ---
alias claude="claude --model cc/claude-opus-4-8"
alias c-opus="claude --model cc/claude-opus-4-8"
alias c-think="claude --model ag/claude-opus-4-6-thinking"
alias c-sonnet="claude --model cc/claude-sonnet-4-6"
alias c-gemini="claude --model gc/gemini-3-pro-preview"
alias c-gpt="claude --model cx/gpt-5.5"
alias c-fast="claude --model oc/deepseek-v4-flash-free"

# --- Detect model (dùng cho smart_chat và command_not_found) ---
_detect_model() {
    local input="$1"
    local intent=$(python3 ~/.local/bin/ai-classify.py "$input" 2>/dev/null)
    case "$intent" in
        DEEP_THINK)  echo "cc/claude-opus-4-8|🧠 OPUS 4.8|TEXT"; return ;;
        CODE_FORMAT)
            local lower=$(echo "$input" | awk '{print tolower($0)}')
            if [[ "$lower" =~ (docx|pdf|xuất|tạo.*file|convert|export|ghi|lưu file) ]]; then
                echo "cc/claude-sonnet-4-6|💻 SONNET|TOOL"
            else
                echo "cc/claude-sonnet-4-6|💻 SONNET|TEXT"
            fi
            return ;;
        LANGUAGE)    echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO|TEXT"; return ;;
        ENGLISH)     echo "oc/gpt-5-5|🌐 GPT-5.5|TEXT"; return ;;
        QUICK)       echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK|TEXT"; return ;;
    esac
    # Fallback Regex
    local lower=$(echo "$input" | awk '{print tolower($0)}')
    if [[ "$lower" =~ (phân tích|chiến lược|kế hoạch|insight|quyết định|rủi ro|fraud|cung cầu|supply|demand|tâm lý|hành vi|sla|root cause|nguyên nhân|okr|kpi|benchmark|retention|churn|ltv) ]]; then
        echo "cc/claude-opus-4-8|🧠 OPUS 4.8|TEXT"
    elif [[ "$lower" =~ (english|tiếng anh|proposal|hq|leadership|global|board|investor|international|official|formal) ]]; then
        echo "oc/gpt-5-5|🌐 GPT-5.5|TEXT"
    elif [[ "$lower" =~ (thông báo|zalo|viết lại|caption|kịch bản|nội dung|tóm tắt|dịch|cạnh tranh|grab|be |xanhsm|competitive) ]]; then
        echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO|TEXT"
    elif [[ "$lower" =~ (hỏi nhanh|định nghĩa|là gì|nhanh|quick|regex|tính toán|giải thích) ]]; then
        echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK|TEXT"
    elif [[ "$lower" =~ (docx|pdf|xuất|tạo.*file|định dạng|chuyển đổi|convert|export|ghi|lưu file) ]]; then
        echo "cc/claude-sonnet-4-6|💻 SONNET|TOOL"
    elif [[ "$lower" =~ (sql|query|html|code|dashboard|báo cáo|lark|markdown|lập trình|script|file) ]]; then
        echo "cc/claude-sonnet-4-6|💻 SONNET|TEXT"
    else
        echo "cc/claude-opus-4-8|🤖 OPUS 4.8|TEXT"
    fi
}

# --- Smart Chat REPL: gõ "chat" để vào ---
smart_chat() {
    local first_msg=true
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  🤖 Smart Chat — tự động routing model  ║"
    echo "║  Gõ 'exit' hoặc Ctrl+C để thoát         ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    while true; do
        echo -n "$(tput setaf 6)You ▶$(tput sgr0) "
        read -r input

        [[ -z "$input" ]] && continue
        [[ "$input" =~ ^(exit|quit|bye|thoát|q)$ ]] && echo "👋 Tạm biệt!" && break

        local result=$(_detect_model "$input")
        local model="${result%%|*}"
        local remainder="${result#*|}"
        local label="${remainder%%|*}"
        local mode="${remainder#*|}"

        echo -e "\n$(tput setaf 3)$label$(tput sgr0)\n"

        if [[ "$mode" == "TOOL" ]]; then
            echo -e "\033[2m🔧 Tool Mode — gõ /exit sau khi xong để quay lại đây\033[0m"
            if [[ "$first_msg" == true ]]; then
                claude --model "$model" --dangerously-skip-permissions "$input"
                first_msg=false
            else
                claude --model "$model" --dangerously-skip-permissions --continue "$input"
            fi
        else
            if [[ "$first_msg" == true ]]; then
                claude --model "$model" -p "$input"
                first_msg=false
            else
                claude --model "$model" --continue -p "$input"
            fi
        fi
        echo ""
    done
}
alias chat="smart_chat"
alias start="smart_chat"

# --- Command Not Found → Auto-route to AI ---
command_not_found_handler() {
    local input="$*"
    local result=$(_detect_model "$input")
    local model="${result%%|*}"
    local label="${result##*|}"
    echo -e "\n$(tput setaf 3)$label$(tput sgr0)\n"
    claude --model "$model" --continue -p "$input"
    return 0
}
# ============================================
