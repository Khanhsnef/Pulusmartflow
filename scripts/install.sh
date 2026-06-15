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

# ─── Bước 1: Kiểm tra Python và httpx ───
echo -e "${YELLOW}[1/6] Kiểm tra Python...${NC}"
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}❌ Python3 chưa cài. Cài tại: https://www.python.org${NC}"
    exit 1
fi
python3 -c "import httpx" 2>/dev/null || {
    echo -e "${YELLOW}   Đang cài httpx...${NC}"
    pip3 install httpx -q
}
echo -e "${GREEN}✅ Python OK${NC}"

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
echo -e "${YELLOW}[5/6] Tối ưu hóa cấu hình Claude Code (Token limits, Prompt cache, MCPs)...${NC}"
python3 "$SCRIPT_DIR/scripts/optimize_claude_config.py"
echo -e "${GREEN}✅ Claude Code Config OK${NC}"

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
