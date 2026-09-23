# CLAUDE.md — hướng dẫn cho Claude Code khi làm việc trong repo này

## Dự án là gì

Target System (SwarmSentinel) — testbed cho đề tài VSOC-19 (Attacker System tự động red-team các agent phòng thủ). Đây KHÔNG phải deliverable được chấm điểm; đây là "bia tập" mà Attacker System (repo khác, ngoài phạm vi này) sẽ tấn công.

Đọc theo thứ tự khi cần context: `docs/00-tong-quan.md` → `docs/01-requirements.md` (yêu cầu) → `docs/02-design.md` (kiến trúc mục tiêu) → `docs/03-checklist.md` (trạng thái build thật) → `PLAN.md` (thứ tự làm + mốc thời gian).

## Kiến trúc 2 lớp

- **Lớp agentic** (`core/`): agent-a, agent-b, gateway, host-registry, rag, tools, common — lõi xử lý alert (2-agent LangGraph).
- **Lớp ingest & lab tấn công** (`ingest/`): firewall, dvwa, wazuh-*, ingest-api, dispatcher, attacker, tailscale — sinh alert thật từ lab tấn công mạng.
- 2 lớp nối nhau đúng 1 điểm: `dispatcher → agent-a`. Không được bắc cầu network nào khác ngoài quy tắc đã ghi trong `docs/02-design.md` mục 2.

## Quy ước bắt buộc (đừng tự ý đổi)

- Compose project: `name: targetsystem`. Prefix container/volume/network: `ts-`. Không dùng brand cá nhân (`vg-`, `swarm-`...) — xem `PLAN.md` mục 1.
- Gọi tên trong code/comment/docs: "lớp agentic", "lớp ingest & lab tấn công" — không đặt tên riêng kiểu sản phẩm cho từng lớp.
- Route, status code, response body, tên scope PHẢI khớp `testbed_spec.md` (`FR-T9` trong `docs/01-requirements.md`) — đây là hợp đồng cứng với Attacker System, không tự ý đổi format lỗi/route mà không ghi chú lại trong `docs/03-checklist.md` mục C.
- Mọi output phụ thuộc LLM phải đánh dấu `mode: "llm" | "heuristic"` — không được để lẫn, không được âm thầm heuristic rồi báo cáo như đã test LLM thật (NFR-2).
- Test bắt buộc chạy pass offline (không cần LLM key) — test cần LLM thật thì skip có lý do rõ ràng khi thiếu `RUN_LLM_TESTS=1`, không skip im lặng.

## Thứ tự build

Theo đúng 8 bước trong `PLAN.md` — không nhảy cóc sang lớp ingest khi lớp agentic (`core/`) chưa có test pass. Sau mỗi bước hoàn thành: cập nhật `docs/03-checklist.md` (tick ✅ đúng hạng mục, kèm ghi chú) trong CÙNG commit với code — checklist phải luôn khớp code thật, không lệch.

## Test

```
python -m pytest tests/unit tests/integration -q
```
(không chạy `pytest` trực tiếp nếu container có `.dockerignore` loại `tests/` khỏi build context — phải mount đè khi chạy trong container, xem `docs/02-design.md` mục 9.)

## Việc chưa chốt — hỏi trước khi build

- Route `/agent-b/read_alert`: có trong `testbed_spec.md` §3 nhưng mục đích chưa rõ. Đừng tự đoán và implement — hỏi team Attacker System trước (xem `docs/03-checklist.md` A13/C5).
