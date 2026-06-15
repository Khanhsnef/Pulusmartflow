<div align="center">

# 🤖 PuluSmartFlow

**Hệ thống AI cá nhân tự động định tuyến — Smart Router + Multi-Agent**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell: zsh](https://img.shields.io/badge/Shell-zsh-blue.svg)](https://www.zsh.org/)
[![Python: 3.8+](https://img.shields.io/badge/Python-3.8+-green.svg)](https://www.python.org/)

*Gõ `chat` — hệ thống tự chọn đúng AI phù hợp nhất cho từng câu hỏi*

</div>

---

## ✨ Tính Năng Nổi Bật

| Tính năng | Mô tả |
|:----------|:------|
| 🧠 **Smart Router v3** | AI phân loại ý định (Haiku/Flash) + Regex fallback → chọn model tự động |
| 💰 **Tối ưu token tự động** | Prompt cache, budget control, route miễn phí cho câu hỏi nhanh |
| 🤖 **9 Sub-Agents chuyên biệt** | SQL Analyst, Report Writer, Driver Comms, Event Planner... |
| 🔄 **Hybrid Mode** | Tự chuyển Tool Mode khi cần tạo file/chạy script |
| 💾 **Auto-backup** | Git push + Google Drive sync sau mỗi phiên |

---

## 🏗️ Kiến Trúc

```
Câu hỏi của bạn
       │
       ▼
┌─────────────────┐     Timeout 8s     ┌────────────────────┐
│  AI CLASSIFIER  │ ─────────────────► │   REGEX FALLBACK   │
│  (Haiku/Flash/  │    nếu thất bại    │  25+ từ khóa       │
│   DeepSeek)     │                    │  tiếng Việt/Anh    │
└────────┬────────┘                    └──────────┬─────────┘
         │                                        │
         └──────────────────┬─────────────────────┘
                            ▼
              ┌─────────────────────────┐
              │      MODEL SELECTION    │
              ├─────────────────────────┤
              │ 🧠 Opus 4.8   │ Chiến lược, P&L, phân tích  │
              │ 💻 Sonnet 4.6 │ Code, SQL, HTML, format      │
              │ ⚡ Gemini Pro │ Viết lách, dịch, content     │
              │ 🌐 GPT-5.5   │ Tiếng Anh, báo cáo HQ        │
              │ 💨 DeepSeek  │ Hỏi nhanh (MIỄN PHÍ)         │
              └─────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────┐
              │   9ROUTER / Headroom    │
              │   Local proxy gateway  │
              └─────────────────────────┘
```

---

## 🚀 Cài Đặt Nhanh

### Yêu Cầu

- **macOS / Linux**: `zsh` hoặc `bash`
- **Windows**: `PowerShell 3.0+`
- Python 3.8+ với `httpx`: `pip install httpx`
- [Claude Code CLI](https://docs.anthropic.com/claude-code)
- [9Router](https://9router.dev) — Local LLM gateway (cần API key)

### Clone repo

```bash
git clone https://github.com/khanhsnef/Pulusmartflow.git
cd Pulusmartflow
```

### Chạy script cài đặt

#### 🍎 Môi trường macOS / Linux (zsh/bash):
```bash
chmod +x scripts/install.sh
./scripts/install.sh
```

#### 🪟 Môi trường Windows (PowerShell):
Mở PowerShell và chạy lệnh sau để thiết lập quyền thực thi và chạy installer:
```powershell
Set-ExecutionPolicy Bypass -Scope Process
.\scripts\install.ps1
```

Kịch bản cài đặt sẽ tự động:
- Cài đặt AI Classifier (`ai-classify.py`) vào thư mục bin cục bộ.
- Thêm cấu hình Smart Router tự động định tuyến vào file shell profile (`~/.zshrc` hoặc `$PROFILE`).
- Tự động trộn (merge) các cấu hình tối ưu token từ mẫu `templates/claude.json` vào file cấu hình Claude Code (`~/.claude.json`).
- Tạo cấu trúc thư mục workspace mẫu.

### Cấu hình API Key & Khởi động

#### 🍎 macOS / Linux:
Chỉnh sửa cấu hình API Key trong `~/.zshrc`:
```bash
export ANTHROPIC_BASE_URL="http://127.0.0.1:8787/v1"   # 9Router local
export ANTHROPIC_API_KEY="your-9router-api-key-here"
```
Chạy lệnh reload shell và bắt đầu dùng:
```bash
source ~/.zshrc
chat  # Bắt đầu sử dụng!
```

#### 🪟 Windows (PowerShell):
Mở file Profile bằng Notepad:
```powershell
notepad $PROFILE
```
Chỉnh sửa dòng cấu hình API Key:
```powershell
$env:ANTHROPIC_BASE_URL = "http://127.0.0.1:8787/v1"
$env:ANTHROPIC_API_KEY = "your-9router-api-key-here"
```
Reload profile và bắt đầu dùng:
```powershell
. $PROFILE
chat  # Bắt đầu sử dụng!
```

---

## 📖 Hướng Dẫn Sử Dụng

### Lệnh chính

```bash
chat          # Mở Smart Chat REPL — cách dùng tối ưu nhất
start         # Alias của chat
ai "câu hỏi" # One-shot: hỏi 1 câu, không vào chế độ chat
```

### Bảng routing từ khóa

| Từ khóa (ví dụ) | Model | Dùng cho |
|:----------------|:------|:---------|
| `phân tích`, `chiến lược`, `insight`, `P&L`, `OKR`, `rủi ro` | 🧠 **Opus 4.8** | Tư duy sâu, ra quyết định |
| `sql`, `code`, `html`, `lark`, `dashboard`, `docx` | 💻 **Sonnet 4.6** | Lập trình, format |
| `thông báo`, `zalo`, `dịch`, `caption`, `tóm tắt` | ⚡ **Gemini Pro** | Viết lách, ngôn ngữ |
| `english`, `proposal`, `hq`, `global`, `investor` | 🌐 **GPT-5.5** | Tiếng Anh chuẩn quốc tế |
| `hỏi nhanh`, `là gì`, `tính toán`, `nhanh` | 💨 **DeepSeek** | Tra cứu nhanh (miễn phí) |

### Ép model thủ công

```bash
c-opus    # Claude Opus 4.8 — Max brain
c-think   # Claude Opus 4.6 Thinking — Deep logic
c-sonnet  # Claude Sonnet 4.6 — Code/Format
c-gemini  # Gemini Pro — Viết lách/Dịch
c-gpt     # GPT-5.5 — English/HQ
c-fast    # DeepSeek Flash — Miễn phí
```

### Tính năng đặc biệt

**🔀 Hybrid Mode:**  
Trong `chat`, thêm từ khóa `tạo file / docx / xuất / lưu` → hệ thống tự bật Tool Mode (đầy đủ quyền). Sau khi xong gõ `/exit` để trở lại chat.

**⌨️ Command Not Found:**  
Gõ thẳng câu hỏi vào terminal (không phải lệnh hệ thống) → AI tự trả lời.

---

## 📁 Cấu Trúc Repo

```
Pulusmartflow/
├── README.md                    # Tài liệu này
├── scripts/
│   ├── install.sh               # Script cài đặt cho macOS/Linux (Bash)
│   ├── install.ps1              # Script cài đặt cho Windows (PowerShell)
│   ├── setup_smart_router.sh    # Chỉ setup Smart Router (Bash)
│   └── optimize_claude_config.py # Python script trộn cấu hình tối ưu token
├── agents/                      # 9 Sub-agent templates
│   ├── sql-analyst.md
│   ├── report-writer.md
│   ├── competitive-intel.md
│   ├── driver-comms.md
│   ├── landing-page-builder.md
│   ├── content-writer.md
│   ├── event-planner.md
│   ├── meeting-prep.md
│   └── weekly-review.md
├── templates/
│   ├── CLAUDE.md                # Template context công việc
│   ├── AGENTS.md                # Template system prompt
│   ├── claude.json              # Template cấu hình Claude Code tối ưu token
│   └── powershell-profile.ps1   # Template Smart Router cho Windows
├── ai-classify.py               # AI Intent Classifier (Python)
└── zshrc-snippet.sh             # Phần thêm vào ~/.zshrc cho macOS/Linux
```

---

## 💰 Logic Tối Ưu Token

Hệ thống có **10 lớp tối ưu** để giảm thiểu chi phí:

1. **Prompt Cache 1h** — Tái sử dụng context, tiết kiệm ~90% input token
2. **Token Budget per Tool** — Bash/Grep/Snip có giới hạn riêng
3. **Brevity Mode** — Hard cap output, tránh AI "nói dài"
4. **Haiku Classifier** — Phân loại ý định với model rẻ nhất (60x rẻ hơn Opus)
5. **DeepSeek FREE routing** — Câu hỏi nhanh = $0
6. **Headroom Proxy** — Rate limit manager tự động
7. **AgentMemory** — Long-term memory, không nhắc lại context mỗi phiên
8. **`/model` switch** — Đổi model không tạo session mới
9. **Compact Mechanism** — Nén context khi >150K tokens
10. **Two-Stage Classifier** — Chỉ dùng model lớn khi thực sự cần

### ⚙️ Cách Áp Dụng Tự Động
Khi bạn chạy script cài đặt `./scripts/install.sh`, hệ thống sẽ hỏi bạn trước khi trộn (merge) các cấu hình tối ưu này từ `templates/claude.json` vào cấu hình Claude Code của bạn tại `~/.claude.json`.

> [!WARNING]
> Các cấu hình tối ưu sử dụng các khóa bắt đầu bằng `tengu_*` (ví dụ: `tengu_swann_brevity`, `tengu_pewter_kestrel`). Đây là các tham số nội bộ chưa công bố chính thức của Claude Code dùng để cấu hình giới hạn token và tần suất nén ngữ cảnh. Việc áp dụng các khóa này có thể không tương thích hoàn toàn nếu phiên bản Claude Code của bạn thay đổi trong tương lai. Bạn có thể bỏ qua bước này khi cài đặt nếu muốn giữ cấu hình mặc định.

### ⚠️ Bảo mật & Quyền hạn (Danger Mode)
Để tránh rủi ro mã độc tự động chạy lệnh hoặc xóa tệp tin hệ thống ngoài ý muốn, PuluSmartFlow mặc định tắt chế độ bỏ qua phân quyền.
*   **Chế độ An toàn (Mặc định - `chat`)**: Mọi hành động đọc/ghi file hoặc thực thi lệnh shell ngoài các vùng cho phép đều sẽ yêu cầu bạn xác nhận thủ công (nhấn `y/n`).
*   **Chế độ Cấp quyền nhanh (Opt-in - `chat!`)**: Nếu bạn hoàn toàn tin tưởng AI và muốn chạy tự động không cần hỏi, hãy khởi động bằng lệnh `chat!` thay vì `chat`.

---

## 🤖 Sub-Agents

Đặt file agent vào `.claude/agents/` trong workspace. Claude tự kích hoạt đúng agent theo task.

| Agent | Kích hoạt khi... |
|:------|:----------------|
| `sql-analyst.md` | Cần query, phân tích dữ liệu |
| `report-writer.md` | Viết báo cáo có cấu trúc |
| `competitive-intel.md` | Phân tích đối thủ cạnh tranh |
| `driver-comms.md` | Viết thông báo, script cho đội nhóm |
| `landing-page-builder.md` | Tạo trang HTML đẹp |
| `content-writer.md` | Caption, blog, LinkedIn |
| `event-planner.md` | Lên kế hoạch sự kiện |
| `meeting-prep.md` | Chuẩn bị trước cuộc họp |
| `weekly-review.md` | Review cuối tuần |

---

## ⚙️ Tùy Chỉnh

### Thêm từ khóa routing

Chỉnh sửa trong `~/.zshrc` (hàm `_regex_route`):

```bash
# Thêm vào nhóm DEEP_THINK:
if [[ "$lower" =~ (từ_khóa_mới|another_keyword) ]]; then
    echo "cc/claude-opus-4-8|🧠 OPUS 4.8 (regex)"
```

### Thêm model mới

```bash
# Thêm alias:
alias c-mymodel="claude --model provider/model-name"

# Thêm vào _intent_to_model():
NEW_INTENT) echo "provider/model-name|🆕 MY MODEL (AI-routed)" ;;
```

---

## 🔧 Troubleshooting

| Vấn đề | Giải pháp |
|:--------|:----------|
| `command not found: chat` | `source ~/.zshrc` |
| AI không trả lời | Kiểm tra 9Router: `9router --tray` |
| Classifier trả về FALLBACK liên tục | `pip3 install httpx` |
| Tool Mode không bật | Thêm "tạo file" hoặc "docx" vào prompt |

---

## 📄 License

MIT — Tự do sử dụng, chỉnh sửa và chia sẻ.

---

<div align="center">

*Được xây dựng với ❤️ bởi [khanhsnef](https://github.com/khanhsnef)*

**[⭐ Star nếu hữu ích!](https://github.com/khanhsnef/Pulusmartflow)**

</div>
