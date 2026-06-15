#!/usr/bin/env python3
"""
AI Intent Classifier — Smart Router v3
Gọi thẳng 9Router (SSE format) bằng httpx. Tương thích Python 3.14+.
Dùng Claude Haiku (nhanh + rẻ) để phân loại ý định chính xác.

Trả về 1 trong 5 nhãn:
  DEEP_THINK  → cc/claude-opus-4-8
  CODE_FORMAT → cc/claude-sonnet-4-6
  LANGUAGE    → gc/gemini-3-pro-preview
  ENGLISH     → oc/gpt-5-5
  QUICK       → oc/deepseek-v4-flash-free
"""

import sys
import os
import json


def parse_9router_response(raw_text: str) -> dict:
    """
    9Router trả về: <JSON>{...}data: [DONE]\n\n
    Trích xuất JSON object đầu tiên.
    """
    text = raw_text.strip()
    brace_count = 0
    json_end = -1
    for i, ch in enumerate(text):
        if ch == '{':
            brace_count += 1
        elif ch == '}':
            brace_count -= 1
            if brace_count == 0:
                json_end = i + 1
                break
    if json_end == -1:
        return {}
    return json.loads(text[:json_end])


def extract_content(data: dict) -> str:
    """Trích xuất text từ response, ưu tiên content rồi đến reasoning_content."""
    try:
        msg = data["choices"][0]["message"]
        content = msg.get("content", "").strip()
        if content:
            return content
        # DeepSeek reasoning model: lấy từ reasoning_content
        return msg.get("reasoning_content", "").strip()
    except Exception:
        return ""


SYSTEM_PROMPT = """You are an intent classifier. Read the user prompt and return ONLY one label with no explanation:

DEEP_THINK   - strategic analysis, business decisions, insight, root cause analysis, trade-off, P&L, SLA, risk, fraud, supply-demand, planning, OKR, retention, churn
CODE_FORMAT  - code, programming, SQL, query, HTML, CSS, script, dashboard, markdown, reports, landing page, UI, regex, Excel formula
LANGUAGE     - rewrite text, notifications, team comms, captions, content, summarize, translate, grammar check, competitor analysis
ENGLISH      - write in English, proposal, HQ, leadership, global, board, investor deck, pitch, official, formal letter, international audience
QUICK        - quick question, definition, short explanation, simple calculation, lookup, quick check

Return ONLY the label. No punctuation, no explanation."""


def classify(prompt: str) -> str:
    try:
        import httpx

        base_url = os.environ.get("ANTHROPIC_BASE_URL", "http://127.0.0.1:8787/v1").rstrip("/")
        api_key  = os.environ.get("ANTHROPIC_API_KEY", "sk-local")

        # Thử lần lượt: Haiku (nhanh/rẻ) → Gemini Flash → DeepSeek (với nhiều token hơn)
        models_to_try = [
            ("cc/claude-haiku-4-5", 20),    # Haiku: reasoning ngắn, output chính xác
            ("gc/gemini-3-flash",   20),    # Gemini Flash: nhanh, không có reasoning overhead
            ("oc/deepseek-v4-flash-free", 200),  # DeepSeek: cần nhiều token do reasoning
        ]

        with httpx.Client(timeout=8.0) as client:
            for model, max_tok in models_to_try:
                try:
                    payload = {
                        "model": model,
                        "messages": [
                            {"role": "system", "content": SYSTEM_PROMPT},
                            {"role": "user",   "content": prompt}
                        ],
                        "max_tokens": max_tok,
                        "temperature": 0
                    }
                    resp = client.post(
                        f"{base_url}/chat/completions",
                        headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
                        content=json.dumps(payload)
                    )
                    resp.raise_for_status()
                    data = parse_9router_response(resp.text)
                    result = extract_content(data).upper()

                    valid = {"DEEP_THINK", "CODE_FORMAT", "LANGUAGE", "ENGLISH", "QUICK"}
                    if result in valid:
                        return result
                    for label in valid:
                        if label in result:
                            return label
                    # Model này không trả về nhãn hợp lệ — thử model tiếp theo
                    continue

                except Exception:
                    continue

        return "FALLBACK"

    except Exception:
        return "FALLBACK"


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("FALLBACK")
        sys.exit(0)
    prompt = " ".join(sys.argv[1:])
    print(classify(prompt))
