#!/bin/bash
# PuluSmartFlow — Script cài đặt tự động
# Chạy: chmod +x scripts/install.sh && ./scripts/install.sh

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║  🤖 PuluSmartFlow — Installer v1.0   ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"

# ─── Bước 1: Kiểm tra Python, Node.js, Claude Code và 9Router ───
echo -e "${YELLOW}[1/6] Kiểm tra các công cụ nền tảng...${NC}"

# Python & httpx
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}❌ Python3 chưa cài. Vui lòng cài đặt tại: https://www.python.org${NC}"
    exit 1
fi
python3 -c "import httpx" 2>/dev/null || {
    echo -e "${YELLOW}   Đang cài thư viện Python httpx...${NC}"
    pip3 install httpx -q
}
echo -e "${GREEN}   Python & httpx OK${NC}"

# Node.js & npm
if ! command -v npm &>/dev/null; then
    echo -e "${RED}❌ Node.js & npm chưa cài. Vui lòng cài đặt tại: https://nodejs.org${NC}"
    exit 1
fi
echo -e "${GREEN}   Node.js & npm OK${NC}"

# Claude Code CLI
if ! command -v claude &>/dev/null; then
    echo -e "${YELLOW}   Đang cài đặt Claude Code CLI (@anthropic-ai/claude-code)...${NC}"
    npm install -g @anthropic-ai/claude-code || {
        echo -e "${RED}❌ Không thể cài đặt global. Vui lòng xử lý lỗi phân quyền npm (EACCES) bằng cách tham khảo: https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally hoặc tự chạy cài đặt thủ công.${NC}"
        exit 1
    }
fi
echo -e "${GREEN}   Claude Code CLI OK${NC}"

# 9Router
if ! command -v 9router &>/dev/null; then
    echo -e "${YELLOW}   Đang cài đặt 9Router...${NC}"
    npm install -g 9router || {
        echo -e "${RED}❌ Không thể cài đặt global. Vui lòng xử lý lỗi phân quyền npm (EACCES) và cài đặt thủ công 9Router.${NC}"
        exit 1
    }
fi
echo -e "${GREEN}   9Router OK${NC}"
echo -e "${GREEN}✅ Các công cụ nền tảng đã sẵn sàng!${NC}"

# ─── Bước 2: Copy ai-classify.py ───
echo -e "${YELLOW}[2/6] Cài AI Classifier...${NC}"
mkdir -p ~/.local/bin
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cp "$SCRIPT_DIR/ai-classify.py" ~/.local/bin/ai-classify.py
chmod +x ~/.local/bin/ai-classify.py
echo -e "${GREEN}✅ ai-classify.py → ~/.local/bin/${NC}"

# ─── Bước 3: Thêm Smart Router vào ~/.zshrc ───
echo -e "${YELLOW}[3/6] Cài Smart Router vào ~/.zshrc...${NC}"
if grep -q "SMART AI ROUTER" ~/.zshrc 2>/dev/null; then
    echo -e "${YELLOW}   ⚠️  Smart Router đã tồn tại. Bỏ qua để tránh trùng lặp.${NC}"
else
    echo -e "${CYAN}🔑 Nhập API Key 9Router của bạn (nhấn Enter để bỏ qua và tự điền sau):${NC}"
    read -r user_key
    
    if [ -n "$user_key" ]; then
        mkdir -p ~/.config/pulu
        cat > ~/.config/pulu/env << ENVEOF
# Configuration env for 9Router and PuluSmartFlow
export ANTHROPIC_BASE_URL="http://127.0.0.1:8787/v1"
export ANTHROPIC_API_KEY="$user_key"
ENVEOF
        chmod 600 ~/.config/pulu/env
        echo -e "${GREEN}   ✅ Đã cấu hình và lưu API Key bảo mật tại ~/.config/pulu/env${NC}"
    fi
    
    cat "$SCRIPT_DIR/zshrc-snippet.sh" >> ~/.zshrc
    echo -e "${GREEN}✅ Smart Router đã thêm vào ~/.zshrc${NC}"
fi

# ─── Bước 4: Tạo cấu trúc workspace ───
echo -e "${YELLOW}[4/6] Tạo cấu trúc workspace...${NC}"
WORKSPACE="${HOME}/Desktop/SmartFlowWorkspace"
mkdir -p "$WORKSPACE/.claude/agents"
mkdir -p "$WORKSPACE/output"

# Copy agent templates
cp "$SCRIPT_DIR/agents/"*.md "$WORKSPACE/.claude/agents/" 2>/dev/null || true
cp "$SCRIPT_DIR/templates/CLAUDE.md" "$WORKSPACE/CLAUDE.md" 2>/dev/null || true
cp "$SCRIPT_DIR/templates/AGENTS.md" "$WORKSPACE/AGENTS.md" 2>/dev/null || true

echo -e "${GREEN}✅ Workspace tạo tại: ${WORKSPACE}${NC}"

# ─── Bước 5: Cấu hình tối ưu Token & MCP ───
echo -e "${YELLOW}[5/6] Bạn có muốn tối ưu hóa cấu hình Claude Code không? (Sử dụng cờ tengu_* để giới hạn token/cache) (y/n):${NC}"
read -r opt_choice
if [[ "$opt_choice" =~ ^[Yy]$ ]]; then
    python3 "$SCRIPT_DIR/scripts/optimize_claude_config.py"
    echo -e "${GREEN}✅ Đã hoàn tất tối ưu hóa cấu hình Claude Code!${NC}"
else
    echo -e "${GREEN}   Bỏ qua bước tối ưu hóa cấu hình Claude Code (Giữ cấu hình mặc định).${NC}"
fi

# ─── Bước 6: Hướng dẫn tiếp theo ───
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  ✅ Cài đặt hoàn tất!                            ║${NC}"
echo -e "${CYAN}╠═══════════════════════════════════════════════════╣${NC}"
echo -e "${CYAN}║  📌 Bước cuối cần làm thủ công:                  ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║  1. Chỉnh API Key trong ~/.zshrc:                 ║${NC}"
echo -e "${CYAN}║     ANTHROPIC_BASE_URL=http://127.0.0.1:8787/v1  ║${NC}"
echo -e "${CYAN}║     ANTHROPIC_API_KEY=your-9router-key            ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║  2. Reload shell:                                 ║${NC}"
echo -e "${CYAN}║     source ~/.zshrc                              ║${NC}"
echo -e "${CYAN}║                                                   ║${NC}"
echo -e "${CYAN}║  3. Bắt đầu dùng:                                ║${NC}"
echo -e "${CYAN}║     chat                                         ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════╝${NC}"
