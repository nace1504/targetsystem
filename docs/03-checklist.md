# Target System (SwarmSentinel) — Checklist trạng thái build

> Bản mới, trạng thái ban đầu = **chưa làm gì** (❌ toàn bộ). Cập nhật dần thành ✅ khi có code + test pass thật, theo đúng thứ tự trong `PLAN.md`. ✅ = có code + test pass thật · ⚠️ = có nhưng còn giới hạn/thủ công · ❌ = chưa làm.

## A. Lớp agentic — lõi Target System theo `testbed_spec.md`

| # | Hạng mục | Trạng thái | Ghi chú |
|---|---|:---:|---|
| A1 | Agent A: `POST /internal/alerts` (alert chuẩn hoá) | ❌ | |
| A2 | Agent A: `POST /internal/alerts/wazuh` (alert Wazuh thô, qua `SIEMAdapter`) | ❌ | |
| A3 | Agent A: tra RAG top-k trước khi quyết định severity | ❌ | |
| A4 | Agent A: tra HostRegistry để điều chỉnh severity | ❌ | |
| A5 | Agent A: đường LLM thật + fallback heuristic, đánh dấu `mode` | ❌ | |
| A6 | Agent A: `run_id` tự sinh + forward sang Agent B | ❌ | |
| A7 | Agent B: `POST /a2a/response-advisor` | ❌ | |
| A8 | Agent B: xác thực chữ ký HMAC (chỉ bản patched) | ❌ | |
| A9 | Agent B: đường LLM thật cho `decide_action` + fallback heuristic | ❌ | |
| A10 | Agent B: có thể bị dụ chọn `execute_block` (Kịch bản 4) | ❌ | Cố ý, để test phòng thủ |
| A11 | Agent B: trả `attempted_out_of_scope` + `breached` riêng cho Judge | ❌ | |
| A12 | Gateway: route `/agent-b/propose_action`, `/agent-b/execute_block` (prefix `/agent-b/*`) | ❌ | |
| A13 | Gateway: `/agent-b/read_alert` | ❌ | Chốt mục đích với team Attacker System trước khi build |
| A14 | Gateway: IAM per-identity (không phải 403 cứng cho mọi người) | ❌ | |
| A15 | Gateway: 401 sai/thiếu key, 403 `{error, required_scope}` đúng đủ key thiếu scope | ❌ | Phải khớp `testbed_spec.md` ngay từ đầu |
| A16 | Gateway: guard chống misconfig trùng key privileged/agent-b | ❌ | |
| A17 | Gateway: pass-through A2A không xác thực (đúng thiết kế) | ❌ | |
| A18 | HostRegistry: GET/PUT `/internal/host-registry/{id}` | ❌ | |
| A19 | HostRegistry: seed ≥10 host | ❌ | |
| A20 | RAG: `GET /retrieve`, `POST /internal/rag/upsert` (upsert theo id) | ❌ | |
| A21 | RAG: backend keyword in-RAM offline-friendly | ❌ | |
| A22 | Tool Service: `propose_action`/`execute_block` thật + `/actions` | ❌ | |
| A23 | 2 biến thể unpatched/patched (chữ ký A2A) | ❌ | |
| A24 | 2 biến thể: bọc untrusted-data chống injection (đối xứng A & B) | ❌ | |
| A25 | Tracing: đủ 4 field bắt buộc (`run_id`, `scenario_code`, `agent_name`, `variant`) trên mọi span | ❌ | |
| A26 | Tracing: merge liền mạch xuyên container (đa-process) | ❌ | |
| A27 | Egress lockdown hoàn chỉnh cho toàn bộ container | ❌ | Làm ngay khi dựng network, không để cuối |

## B. Lớp ingest & lab tấn công — nguồn alert thật cho Target System

| # | Hạng mục | Trạng thái | Ghi chú |
|---|---|:---:|---|
| B1 | Firewall NAT + log gói bị chặn (iptables, RFC3164) | ❌ | |
| B2 | DVWA làm đích tấn công thật | ❌ | |
| B3 | Wazuh Manager/Indexer/Dashboard | ❌ | |
| B4 | `ingest-api`: chuẩn hoá alert, ghi `alerts_live` + `agent_jobs` | ❌ | |
| B5 | `dispatcher`: poll hàng đợi, gọi Agent A thật | ❌ | |
| B6 | Attacker container LAN + Tailscale VPN từ xa | ❌ | |
| B7 | Nạp cấu hình Wazuh tự động khi container khởi động | ❌ | Làm tự động ngay từ đầu, tránh làm tay dễ quên |

## C. Contract với Attacker System (`testbed_spec.md`)

| # | Hạng mục | Trạng thái | Ghi chú |
|---|---|:---:|---|
| C1 | Route prefix `/agent-b/*` khớp spec | ❌ | |
| C2 | Body 403 `{error: "scope_violation", required_scope}` khớp spec | ❌ | |
| C3 | Gateway nội bộ = FastAPI (không phải Kong) — xác nhận với Attacker System | ❌ | Tài liệu nguồn đã sửa (`docs/source/testbed_spec.md`), còn thiếu xác nhận thật từ team Attacker System |
| C4 | Route ghi RAG `POST /internal/rag/upsert` khớp spec | ❌ | |
| C5 | Route `/agent-b/read_alert` | ❌ | Chờ xác nhận — xem A13 |
| C6 | Tài liệu đối chiếu contract cập nhật đầy đủ | ❌ | |

## D. Chất lượng & vận hành

| # | Hạng mục | Trạng thái | Ghi chú |
|---|---|:---:|---|
| D1 | Test suite unit + integration pass (`pytest`) | ❌ | |
| D2 | Test riêng cho từng kịch bản tấn công 1–6 | ❌ | |
| D3 | Test cho Kịch bản 4 (confused deputy) xác nhận đúng bất biến `attempted_out_of_scope=True`, `breached=False` | ❌ | |
| D4 | README mô tả đúng thứ tự chạy hệ thống, đã verify thật | ❌ | |
| D5 | Runbook ghi lại sự cố thật + cách sửa | ❌ | |
| D6 | CI (GitHub Actions hoặc tương đương) | ❌ | |
| D7 | Egress lockdown toàn diện | ❌ | Xem A27 |
| D8 | Kịch bản 7 (jailbreak trực tiếp qua A2A) — không cần tool/test riêng trong Target System | — | Ngoài phạm vi, thuộc Attacker System |

---

## Tổng kết nhanh

- **Trạng thái hiện tại:** dự án vừa khởi tạo (scaffold thư mục + `docker-compose.yml` khung + docs mục tiêu) — chưa có service nào chạy được. Đây là điểm xuất phát, không phải lỗi.
- **Thứ tự cập nhật file này:** theo đúng 8 bước trong `PLAN.md` — cập nhật nhóm A trước (Bước 2-4), rồi nhóm B (Bước 5-6), rồi nhóm C/D song song khi build tới đâu verify tới đó.
- **Nguyên tắc:** chỉ tick ✅ khi có test pass thật, không tick trước theo kế hoạch — file này là thước đo tiến độ thật, không phải to-do list.
