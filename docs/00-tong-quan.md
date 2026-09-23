# Target System (SwarmSentinel) — Tài liệu Tổng quan

> Testbed cho đề tài VSOC-19 — không phải deliverable được chấm (deliverable là Attacker System, nằm ngoài repo này).

## 1. Target System là gì (1 câu)

Một hệ 2-agent giám sát an ninh (SOC) mô phỏng, gồm **lớp agentic** (phân loại alert + đề xuất hành động, có ranh giới quyền hạn thật qua Gateway nội bộ FastAPI middleware — không dùng Kong) nhận alert từ **lớp ingest & lab tấn công** (lab mạng thật + SIEM Wazuh sinh alert thật) — làm bia tập để Attacker System kiểm thử.

## 2. Bộ tài liệu

| # | File | Nội dung |
|---|---|---|
| 00 | `00-tong-quan.md` | File này — bản đồ đọc nhanh |
| 01 | `01-requirements.md` | Yêu cầu chức năng/phi chức năng, phạm vi trong/ngoài |
| 02 | `02-design.md` | Kiến trúc, mạng, route, database, luồng dữ liệu, kịch bản tấn công |
| 03 | `03-checklist.md` | Trạng thái build từng hạng mục (đối chiếu code thật) |
| 04 | `04-detailed-design.md` | Chi tiết kỹ thuật để code thẳng: schema/API chính xác, data flow 7 kịch bản, network/deploy thật, test strategy + fixtures — đọc TRƯỚC khi code bất kỳ module nào |
| — | `source/` | Tài liệu nguồn gốc dự án tổng (đề bài, PRD, TRD, testbed spec, kế hoạch team) — dùng để đối chiếu chi tiết, không phải bản đọc chính |

## 3. Trạng thái

Xem `PLAN.md` (root) cho kế hoạch build đầy đủ + mốc thời gian, và `03-checklist.md` cho trạng thái từng hạng mục — chỉ tick ✅ khi có test pass thật.

*Cây tài liệu tham khảo nhanh: đọc file này → cần yêu cầu/phạm vi xem `01` → cần kiến trúc/kịch bản tấn công xem `02` → **cần code thẳng, cần schema/rule/fixture chính xác xem `04`** → cần biết đã làm đến đâu xem `03` → cần đối chiếu tài liệu gốc dự án tổng xem `source/`.*
