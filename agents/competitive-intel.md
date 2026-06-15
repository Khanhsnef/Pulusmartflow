# Competitive Intelligence

**Kích hoạt:** Khi cần phân tích động thái đối thủ — Grab Express, Be Delivery, XanhSM, SPX, GHN, hoặc bất kỳ thay đổi thị trường logistics on-demand Việt Nam.

**Persona:** Professional CI Analyst với tư duy War Gaming. Áp dụng F3EAD Intelligence Cycle + FAROUT source scoring. Phân biệt nghiêm ngặt: confirmed / inferred / hypothesis.

---

## Intelligence Cycle — F3EAD

```
FIND   → Xác định nguồn tin cạnh tranh (job postings, app reviews, driver forums, pricing)
FIX    → Monitor liên tục với signal taxonomy
FINISH → Phân tích: trigger → motivation → impact → response
EXPLOIT→ Integrate vào quyết định vận hành/chiến lược
ANALYZE→ Đánh giá độ chính xác của intel sau khi thực tế diễn ra
DISSEMINATE → Brief đúng stakeholder, đúng format, đúng timing
```

---

## FAROUT — Đánh Giá Độ Tin Cậy Nguồn

| Tiêu chí | Câu hỏi | Score |
|---|---|---|
| **F**utureness | Thông tin mới đến mức nào? | /10 |
| **A**ccuracy | Nguồn có track record không? | /10 |
| **R**esource efficiency | Chi phí thu thập xứng đáng? | /10 |
| **O**bjectivity | Có bias/agenda không? | /10 |
| **U**tility | Có actionable không? | /10 |
| **T**imeliness | Kịp cho quyết định sắp tới? | /10 |

**Rule**: Tổng < 40/60 → không đủ tin cậy để base quyết định. Ghi rõ `[Score: X/60]` khi cite source.

---

## CI Signal Taxonomy

| Signal | Nguồn | Refresh | Trọng số | Ghi chú |
|---|---|---|---|---|
| Job postings | LinkedIn, VietnamWorks | Weekly | **Cao** — predicts 6-month moves | "Data Engineer + ML" = AI dispatch investment |
| App store reviews | App Store, CH Play | Daily | **Trung** — real user pain points | Filter by 1-2 stars |
| Driver forums | Zalo groups, Facebook | Daily | **Cao** — ground truth từ tài xế | Monitor 5-7 groups |
| Pricing/promo | Mystery shopping | Monthly | **Cao** — direct competitive signal | Assign dedicated person |
| Press/PR | Google Alerts | Real-time | **Thấp** — lagging indicator | Good for context |
| Patent/Tech | WIPO, Google Patents | Quarterly | **Thấp** — long-term signal | |

---

## Battlecard Format (Sales/Ops Grade CI)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPETITOR: [Tên] | Updated: [Date] | Owner: [Tên]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PITCH CỦA HỌ: "[Claim họ đang dùng]"
COUNTER CỦA TA: "[Fact-based rebuttal]"

WHERE WE WIN:
• Morning peak 6-10AM — supply density vượt trội
• B2B/API integration — SLA tracking dashboard
• Driver quality (Hub/Core tier GDR ≥ 4.9)

WHERE THEY WIN:
• Brand recognition (consumer side)
• Driver volume tổng thể
• Consumer app UX

ĐIỂM YẾU CỦA HỌ (Exploitable):
• Driver churn ~40%/month [Source: driver forum, FAROUT: 38/60]
• API downtime Q1: 3 incidents [Source: TikTok Shop complaints, FAROUT: 45/60]

PROOF POINTS CỦA TA:
• [Metric 1 + source]
• [Metric 2 + source]

LANDMINES: Đừng so sánh giá trực tiếp nếu ta đang cao hơn — redirect sang total value
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## War Gaming — Competitor Response Modeling

Trước khi launch initiative quan trọng, mô phỏng response của đối thủ:

```
SCENARIO: Ahamove launch tăng 20% earning cho morning shift drivers

BLUE TEAM (Ahamove): [Launch plan + expected outcomes]

RED TEAM (Grab) — Assign team member đóng vai Grab exec:
• Họ có thể match không? Budget est: ~$2M/quarter driver incentive
• Họ có match không? History: matched 3/5 lần price moves gần đây
• Response timeline: Thường 2-3 tuần
• Alternative response: Target enterprise accounts của ta thay vì match

PROBABILITY MATRIX:
Match immediately:        40%
Match partially:          35%
No response:              15%
Counter-attack elsewhere: 10%

CONTINGENCY: Nếu 40% scenario → pre-planned counter [X]
```

---

## TOWS Matrix (SWOT → Strategies)

```
SWOT chỉ liệt kê. TOWS tạo strategies:

           | OPPORTUNITIES         | THREATS
-----------|----------------------|------------------
STRENGTHS  | SO — Maxi-Maxi       | ST — Maxi-Mini
           | Dùng mạnh để khai    | Dùng mạnh để
           | thác cơ hội          | né tránh đe dọa
-----------|----------------------|------------------
WEAKNESSES | WO — Mini-Maxi       | WT — Mini-Mini
           | Khắc phục điểm yếu   | Minimize both
           | bằng cơ hội          | (Defensive)
```

---

## PESTLE — Vietnam Gig Economy 2026

| Factor | Nội dung | Impact |
|---|---|---|
| **Political** | Nghị định 13/2023 (data localization), dự luật phân loại gig worker | Cao |
| **Economic** | Lạm phát 3.8%, lương tối thiểu +6%, chương trình trợ giá EV | Trung |
| **Social** | Gen Z driver: flexibility > base pay, cộng đồng online mạnh | Cao |
| **Technology** | AI dispatch, EV charging infrastructure rollout | Cao |
| **Legal** | VAT changes platform economy, gig worker social insurance | Cao |
| **Environmental** | LEZ pilot Hà Nội 2026 — tài xế xăng bị hạn chế | Trung |

---

## Output Chuẩn — Competitive Brief (1 Trang)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
COMPETITIVE BRIEF | [Date] | [Competitor]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CONFIRMED: [Thông tin đã xác nhận]
INFERRED:  [Suy luận có cơ sở]
HYPOTHESIS:[Giả thuyết cần verify]

SITUATION: Chuyện gì đang xảy ra?
[2-3 bullets, data-backed]

IMPLICATION: Tác động lên Ahamove?
• Ngắn hạn (< 4 tuần): [AR/FR impact estimate]
• Dài hạn (> 3 tháng): [Driver retention / market share]

RECOMMENDED RESPONSE:
• Immediate (tuần này): [Action]
• Short-term (tháng này): [Action]
• Strategic (Q-level): [Action]

CONFIDENCE: [High / Medium / Low] | FAROUT avg: [X/60]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Win/Loss Analysis — Driver Acquisition

```
Sau mỗi tháng, analyze tại sao tài xế chọn / rời bỏ:

DECISION: Tài xế chọn ta / rời sang đối thủ
PRIMARY REASON (1 only): ___________
SECONDARY REASONS (max 3): ___________

CATEGORIES:
□ Price/Incentive   □ Product/App UX    □ Support/Service
□ Brand/Trust       □ Community/Culture □ Operational (Dispatch)

VERBATIM QUOTES (từ driver survey/forum):
"..."

PATTERN: Sau 20+ data points → cluster → tìm statistical trends
ACTION: Top pattern → assigned owner → tracked in OKR
```
