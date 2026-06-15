
# === SMART AI ROUTER v3 (LLM Intent Classifier + Regex Fallback) ===
# Thêm đoạn này vào cuối file ~/.zshrc
# Sau đó chạy: source ~/.zshrc

# --- Cấu hình 9Router ---
if [ -f "$HOME/.config/pulu/env" ]; then
    source "$HOME/.config/pulu/env"
else
    export ANTHROPIC_BASE_URL="http://127.0.0.1:8787/v1"
    export ANTHROPIC_API_KEY="your-9router-api-key-here"   # ← Thay bằng key của bạn
fi
# --------------------------

# --- Mapping intent → model ---
_intent_to_model() {
    local intent="$1"
    case "$intent" in
        DEEP_THINK)  echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (AI-routed)" ;;
        CODE_FORMAT) echo "cc/claude-sonnet-4-6|💻 SONNET (AI-routed)" ;;
        LANGUAGE)    echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO (AI-routed)" ;;
        ENGLISH)     echo "cx/gpt-5.5|🌐 GPT-5.5 (AI-routed)" ;;
        QUICK)       echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK (AI-routed)" ;;
        *)           echo "" ;;
    esac
}

# --- Regex fallback (không cần API) ---
_regex_route() {
    local lower=$(echo "$1" | awk '{print tolower($0)}')
    if [[ "$lower" =~ (phân tích|chiến lược|kế hoạch|logic|kiến trúc|hệ thống|quy hoạch|tư duy|chiều sâu|đánh đổi|trade-off|p\&l|sla|nguyên nhân gốc rễ|root cause|insight|quyết định|decision|rủi ro|fraud|cung cầu|supply|demand|tâm lý|hành vi|okr|kpi|benchmark|driver journey|retention|churn|ltv) ]]; then
        echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (regex)"
    elif [[ "$lower" =~ (english|tiếng anh|proposal|hq|headquarter|leadership|international|global|board|presentation|investor|deck|pitch|official|formal|write in english|draft in english) ]]; then
        echo "cx/gpt-5.5|🌐 GPT-5.5 (regex)"
    elif [[ "$lower" =~ (dịch thuật|dịch|thông báo|tài xế|zalo|chính tả|ngữ pháp|viết lại|caption|kịch bản|nội dung|tóm tắt|đọc file|log|competitive|cạnh tranh|grab|be |xanhsm) ]]; then
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

    # 1. Thử Regex trước để phản hồi tức thì dưới 10ms
    local result=$(_regex_route "$prompt")
    local model="${result%%|*}"
    local label="${result#*|}"

    # 2. Nếu Regex trả về nhãn mặc định (default), mới dùng AI Classifier để phân tích sâu
    if [[ "$label" =~ "default" ]]; then
        local intent=$(python3 ~/.local/bin/ai-classify.py "$prompt" 2>/dev/null)
        local ai_result=$(_intent_to_model "$intent")
        if [[ -n "$ai_result" ]]; then
            result="$ai_result"
            model="${result%%|*}"
            label="${result#*|}"
        fi
    fi

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
    local lower=$(echo "$input" | awk '{print tolower($0)}')
    
    # 1. Thử Regex trước để tối ưu hóa độ trễ (latency < 10ms)
    if [[ "$lower" =~ (phân tích|chiến lược|kế hoạch|insight|quyết định|rủi ro|fraud|cung cầu|supply|demand|tâm lý|hành vi|sla|root cause|nguyên nhân|okr|kpi|benchmark|driver journey|retention|churn|ltv) ]]; then
        echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (regex)|TEXT"
    elif [[ "$lower" =~ (english|tiếng anh|proposal|hq|leadership|global|board|investor|international|official|formal) ]]; then
        echo "cx/gpt-5.5|🌐 GPT-5.5 (regex)|TEXT"
    elif [[ "$lower" =~ (thông báo|zalo|tài xế|viết lại|caption|kịch bản|nội dung|tóm tắt|dịch|cạnh tranh|grab|be |xanhsm|competitive) ]]; then
        echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO (regex)|TEXT"
    elif [[ "$lower" =~ (hỏi nhanh|định nghĩa|là gì|nhanh|quick|regex|tính toán|giải thích) ]]; then
        echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK (regex)|TEXT"
    elif [[ "$lower" =~ (docx|pdf|xuất|tạo.*file|định dạng|chuyển đổi|convert|export|ghi|lưu file) ]]; then
        echo "cc/claude-sonnet-4-6|💻 SONNET (regex)|TOOL"
    elif [[ "$lower" =~ (sql|query|html|code|dashboard|báo cáo|lark|markdown|lập trình|script) ]]; then
        # Loại bỏ regex "file" quá rộng để tránh false-positive
        echo "cc/claude-sonnet-4-6|💻 SONNET (regex)|TEXT"
    else
        # 2. Không khớp từ khóa đặc trưng -> Gọi AI Classifier để phân loại chính xác
        local intent=$(python3 ~/.local/bin/ai-classify.py "$input" 2>/dev/null)
        case "$intent" in
            DEEP_THINK)  echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (AI)|TEXT"; return ;;
            CODE_FORMAT)
                if [[ "$lower" =~ (docx|pdf|xuất|tạo.*file|convert|export|ghi|lưu file) ]]; then
                    echo "cc/claude-sonnet-4-6|💻 SONNET (AI)|TOOL"
                else
                    echo "cc/claude-sonnet-4-6|💻 SONNET (AI)|TEXT"
                fi
                return ;;
            LANGUAGE)    echo "gc/gemini-3-pro-preview|⚡ GEMINI PRO (AI)|TEXT"; return ;;
            ENGLISH)     echo "cx/gpt-5.5|🌐 GPT-5.5 (AI)|TEXT"; return ;;
            QUICK)       echo "oc/deepseek-v4-flash-free|💨 DEEPSEEK (AI)|TEXT"; return ;;
        esac
        
        # Mặc định cuối cùng
        echo "cc/claude-opus-4-8|🤖 OPUS 4.8 (default)|TEXT"
    fi
}

# --- Smart Chat REPL: gõ "chat" để vào ---
smart_chat() {
    local first_msg=true
    local danger_mode=false
    
    if [[ "$1" == "!" ]]; then
        danger_mode=true
    fi

    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║  🤖 Smart Chat — tự động routing model  ║"
    if [[ "$danger_mode" == true ]]; then
        echo "║  ⚠️ DANGER MODE: Tự động xác thực quyền  ║"
    else
        echo "║  🔒 SAFE MODE: Yêu cầu xác thực quyền    ║"
    fi
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
            if [[ "$danger_mode" == true ]]; then
                echo -e "\033[2m🔧 Đang bật giao diện Công Cụ (TỰ ĐỘNG CẤP QUYỀN - Hãy gõ /exit sau khi xong)\033[0m"
                if [[ "$first_msg" == true ]]; then
                    claude --model "$model" --dangerously-skip-permissions "$input"
                    first_msg=false
                else
                    claude --model "$model" --dangerously-skip-permissions --continue "$input"
                fi
            else
                echo -e "\033[2m🔧 Đang bật giao diện Công Cụ (An toàn - Hãy gõ /exit sau khi xong)\033[0m"
                if [[ "$first_msg" == true ]]; then
                    claude --model "$model" "$input"
                    first_msg=false
                else
                    claude --model "$model" --continue "$input"
                fi
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
alias "chat!"="smart_chat !"

# --- Command Not Found → Auto-route to AI ---
export _PULU_CNF_DEPTH=0
command_not_found_handler() {
    local input="$*"
    if [[ $_PULU_CNF_DEPTH -ge 1 ]]; then
        echo -e "\n❌ \033[1;31m[Pulu Circuit Breaker]\033[0m Phát hiện đệ quy lặp lệnh. Hủy thực thi."
        return 127
    fi
    export _PULU_CNF_DEPTH=$((_PULU_CNF_DEPTH + 1))

    local result=$(_detect_model "$input")
    local model="${result%%|*}"
    local remainder="${result#*|}"
    local label="${remainder%%|*}"
    
    echo -e "\n$(tput setaf 3)$label$(tput sgr0)\n"
    claude --model "$model" --continue -p "$input"
    
    export _PULU_CNF_DEPTH=0
    return 0
}
# Fallback cho Bash shell của một số dòng máy Linux/Ubuntu
command_not_found_handle() {
    command_not_found_handler "$@"
}
# ============================================
