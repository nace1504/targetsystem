# Target System (SwarmSentinel)

Testbed cho đề tài VSOC-19 — **không phải deliverable được chấm điểm**. Đây là "bia tập" (hệ 2-agent SOC mô phỏng) để Attacker System (repo khác, ngoài phạm vi này) kiểm thử tấn công đối kháng.

## Đọc theo thứ tự

1. [`docs/00-tong-quan.md`](docs/00-tong-quan.md) — bản đồ đọc nhanh + quy ước tên gọi
2. [`docs/01-requirements.md`](docs/01-requirements.md) — yêu cầu chức năng/phi chức năng
3. [`docs/02-design.md`](docs/02-design.md) — kiến trúc, route, database, kịch bản tấn công
4. [`docs/03-checklist.md`](docs/03-checklist.md) — trạng thái build thật (đối chiếu code)
5. [`PLAN.md`](PLAN.md) — thứ tự build + mốc thời gian
6. [`CLAUDE.md`](CLAUDE.md) — hướng dẫn cho Claude Code khi làm việc trong repo này

## Tài liệu nguồn dự án tổng

[`docs/source/`](docs/source/) — 5 file gốc của cả dự án VSOC-19 (đề bài, PRD, TRD, testbed spec, kế hoạch triển khai của team). 4 file trong `docs/` ở trên là bản viết lại sạch, thống nhất tên gọi, dành riêng cho phần Target System; `docs/source/` là nguyên bản để đối chiếu khi cần.

> `docs/source/testbed_spec.md` đã được sửa lại phần Gateway nội bộ: trước đây ghi nhầm là "Kong", đã sửa thành "middleware FastAPI" đúng theo quyết định đã chốt trong PRD/TRD (Kong chỉ dùng cho Attacker Gateway, thuộc Attacker System, không thuộc Target System này).

## Kiến trúc 2 lớp

- **Lớp agentic** (`core/`) — agent-a, agent-b, gateway (FastAPI middleware, không dùng Kong), host-registry, rag, tools
- **Lớp ingest & lab tấn công** (`ingest/`) — firewall, dvwa, wazuh-*, ingest-api, dispatcher

## Trạng thái

Scaffold ban đầu — chưa có service nào chạy được, đúng thứ tự build xem `PLAN.md` + `docs/03-checklist.md`.
