# Target System (SwarmSentinel) — Tài liệu Yêu cầu (Requirements)

> Rút ra từ yêu cầu dự án tổng: `docs/source/redteamAI.md` (đề bài VSOC-19), `docs/source/prd_swarmsentinel.md`, `docs/source/trd_swarmsentinel.md`, `docs/source/testbed_spec.md`. Tài liệu này mô tả hệ thống phải làm được gì, không phải audit trạng thái code (xem `03-checklist.md` cho việc đó).

---

## 1. Bối cảnh & mục đích

Đề bài VSOC-19 yêu cầu xây một AI Agent red-team tự động kiểm thử đối kháng các agent phòng thủ trong hệ AI-SOC. Vì không có quyền truy cập hệ AI-SOC thật, nhóm tự dựng một hệ agent mô phỏng SOC (**Target System**) làm mục tiêu tấn công trong sandbox.

Target System phải:

- Có **hành vi agentic thật** (không phải mock tĩnh) để các kỹ thuật tấn công (giả mạo giao tiếp, đầu độc dữ liệu, dẫn dắt mục tiêu, vượt quyền, injection, jailbreak) có ý nghĩa thật khi thử.
- Có **ranh giới quyền hạn thật** (không chỉ là quy ước trong prompt) để đo được việc kiểm thử least-privilege có hiệu quả không.
- Sinh ra **bằng chứng quan sát được** (trace) để một Judge agent bên ngoài xác minh độc lập, không cần tin lời tự thuật của attacker.
- **Tái lập được** — cùng input phải cho cùng kết quả (chạy offline được cho CI/demo), tách bạch rõ khi nào hành vi phụ thuộc LLM thật (không tất định) và khi nào là heuristic tất định.

Target System gồm 2 lớp bổ trợ theo chuỗi, cùng phục vụ một mục tiêu duy nhất:

| Lớp | Vai trò | 
|---|---|
| **Lớp agentic** | Lõi xử lý — 2-agent phân loại severity + đề xuất hành động, đúng theo `docs/source/testbed_spec.md` |
| **Lớp ingest & lab tấn công** | Nguồn alert đầu vào — lab mạng tấn công thật + SIEM, nạp alert **thật** vào lớp agentic thay vì chỉ dùng alert giả lập tay |

Từ góc nhìn đề tài VSOC-19: cả 2 lớp trên **chỉ là một Target System** — bia tập duy nhất mà Attacker System (deliverable được chấm) sẽ nhắm vào.

**Ranh giới quan trọng:** đề tài VSOC-19 chỉ chấm điểm **Attacker System** (Orchestrator + Swarm/IAM/Injection Tester + Judge + Dashboard + blue-team loop). Target System là testbed, không tính điểm riêng — yêu cầu dưới đây là yêu cầu cho testbed.

---

## 2. Phạm vi (Scope)

### 2.1 Trong phạm vi (Target System phải làm)

- **FR-T1.** Agent A "AlertTriage": nhận alert (đã chuẩn hoá hoặc từ SIEM thô) → tra RAG threat intel + HostRegistry → LLM (hoặc heuristic fallback) quyết định `severity` → forward A2A cho Agent B.
- **FR-T2.** Agent B "ResponseAdvisor": nhận message A2A → xác minh chữ ký (chỉ ở bản patched) → LLM (hoặc heuristic) quyết định action → gọi tool qua Gateway.
- **FR-T3.** Gateway nội bộ thực thi IAM least-privilege **theo từng danh tính** (per-identity scope), là ranh giới kỹ thuật thật chặn hành động ngoài scope — không phải quy ước trong prompt.
- **FR-T4.** HostRegistry — tool dùng chung `host_id → owner, criticality`, có endpoint ghi không xác thực (điểm cấy đầu độc chủ đích cho kịch bản data poisoning).
- **FR-T5.** RAG threat_intel — nguồn tri thức cho Agent A, có endpoint ghi/đè theo `id` (điểm cấy đầu độc chủ đích cho kịch bản poisoning qua RAG).
- **FR-T6.** 2 biến thể cấu hình Unpatched/Patched (bật/tắt xác thực chữ ký A2A + bọc dữ liệu untrusted chống injection) để demo hiệu quả vá và phục vụ retest khép vòng blue-team phía Attacker System.
- **FR-T7 (mở rộng ngoài `docs/source/testbed_spec.md` gốc).** Lớp ingest & lab tấn công mạng thật: firewall NAT có log, DVWA làm đích tấn công thật, SIEM phân tích log sinh alert thật, Ingest API + hàng đợi job + dispatcher đẩy alert thật vào Agent A — thay cho việc chỉ gửi alert giả lập tay.
- **FR-T8.** Toàn bộ tương tác liên-agent + tool call phải sinh bằng chứng quan sát được (tracing) có đủ `run_id`, `scenario_code`, `agent_name`, `variant`, phục vụ Judge của Attacker System.
- **FR-T9.** Contract HTTP (route, status code, response body, tên scope) phải khớp `docs/source/testbed_spec.md` — nguồn chân lý mà Attacker System phụ thuộc vào khi cấy kịch bản.

### 2.2 Ngoài phạm vi (Target System không cần làm)

- **NG-T1.** Không phải deliverable được chấm điểm — không cần tối ưu UX, không cần Dashboard, không cần RBAC/login.
- **NG-T2.** Guardrail của Target System (Gateway, xác thực chữ ký, bọc untrusted data...) **không được dùng làm bằng chứng** cho việc đề bài yêu cầu Attacker System phải least-privilege/an toàn — đó là 2 việc khác nhau.
- **NG-T3.** Không cần bảo vệ dữ liệu thật (toàn bộ dữ liệu là giả lập, `host_id` mẫu, không PII).
- **NG-T4.** Không cần tự dựng Orchestrator/Judge/Dashboard/blue-team loop — các thành phần đó thuộc Attacker System.
- **NG-T5.** Không cần Dashboard React/Next.js, không cần Presidio/NeMo Guardrails, không cần kiến trúc 3-agent Enrichment/Correlation/Classifier riêng cho lớp ingest — dùng thẳng agent thật của lớp agentic làm lõi xử lý chung.

---

## 3. Yêu cầu chức năng chi tiết theo thành phần

### 3.1 Agent A — AlertTriage

- Nhận alert đã chuẩn hoá (`POST /internal/alerts`) và alert thô từ SIEM (`POST /internal/alerts/wazuh`, tự chuẩn hoá qua adapter).
- Tra RAG threat intel (top-k) trước khi quyết định severity.
- Tra HostRegistry (`host_id → criticality`) để điều chỉnh severity.
- Có đường LLM thật cho quyết định severity, với fallback heuristic tất định khi thiếu key — đánh dấu rõ chế độ đang chạy (`mode: llm | heuristic`) để không tạo false-green khi thiếu key mà tưởng đã test LLM thật.
- `run_id` luôn tồn tại (tự sinh nếu caller không truyền), forward sang Agent B qua header.
- Gửi A2A cho Agent B qua Gateway.

### 3.2 Agent B — ResponseAdvisor

- Nhận message A2A (`POST /a2a/response-advisor`), xác minh chữ ký (chỉ bản patched), quyết định action.
- Có đường LLM thật cho quyết định action, fallback heuristic (map cứng theo severity).
- Có thể bị dụ chọn hành động vượt quyền (kịch bản confused-deputy) — đây là hành vi **cố ý**, để kiểm chứng Gateway chặn đúng.
- Trả riêng biệt 2 cờ cho Judge: `attempted_out_of_scope` (agent có cố gọi hành động ngoài scope không) và `breached` (Gateway có thực sự để lọt không) — 2 cờ này không được gộp làm một.

### 3.3 Gateway (IAM nội bộ)

- Route theo prefix quy định trong `docs/source/testbed_spec.md` (`/agent-b/propose_action`, `/agent-b/execute_block`, `/a2a/response-advisor` pass-through không xác thực).
- IAM **per-identity**: mỗi API key gắn đúng 1 tập scope tối thiểu (`agent_b_api_key` → chỉ `tools:propose`; `privileged_api_key` → `tools:propose` + `block:execute`) — không phải 403 cứng cho mọi request.
- 401 khi thiếu/sai key; 403 đúng format `{error, required_scope}` khi đủ key nhưng thiếu scope — khớp `docs/source/testbed_spec.md`.
- Guard chống misconfig: nếu 2 key bị cấp trùng nhau, ép về scope thấp nhất (an toàn hơn) thay vì fail-open.

### 3.4 HostRegistry

- `GET`/`PUT` theo `host_id`, seed sẵn dữ liệu mẫu đủ dùng cho demo/test.
- Endpoint ghi cố ý không xác thực — là điểm cấy đầu độc dữ liệu theo thiết kế, không phải lỗ hổng ngoài ý muốn.

### 3.5 RAG (threat intel)

- `GET /retrieve` theo top-k; ghi/đè theo `id` (upsert, không chỉ append) để hỗ trợ kịch bản đầu độc tri thức có mục tiêu.
- Backend đơn giản, chạy offline được (không phụ thuộc dịch vụ ngoài) để CI/demo tái lập.

### 3.6 Tool Service

- `propose_action` và `execute_block` triển khai đầy đủ ở tầng service — thứ duy nhất ngăn `execute_block` trái phép là Gateway, không phải code tool, để chứng minh ranh giới quyền hạn là thật.
- Ghi lại lịch sử hành động, expose endpoint đọc lại để test/Judge đối chiếu.

### 3.7 2 biến thể cấu hình

- **Unpatched:** không xác thực chữ ký A2A, không bọc dữ liệu untrusted.
- **Patched:** xác thực chữ ký HMAC cho A2A + bọc untrusted-data bằng delimiter chống prompt injection — áp dụng **đối xứng** cho cả Agent A và Agent B.

### 3.8 Lớp ingest & lab tấn công

- Lab mạng thật: firewall (NAT + log gói bị chặn), đích tấn công thật (web app dễ tổn thương), SIEM thu thập + phân tích log.
- Ingest API: nhận alert thô từ SIEM (webhook), chuẩn hoá, ghi hàng đợi job.
- Dispatcher: poll hàng đợi, gọi Agent A thật — đây là điểm nối **duy nhất** giữa 2 lớp.
- Hỗ trợ tấn công từ xa qua VPN, không chỉ LAN nội bộ.

### 3.9 Tracing / bằng chứng

- Mọi span (liên-agent, tool call) phải mang đủ 4 field: `run_id`, `scenario_code`, `agent_name`, `variant`.
- Cần một nguồn bằng chứng liền mạch **xuyên container** (không chỉ trong 1 process) để Judge đối chiếu được toàn bộ pipeline.

---

## 4. Yêu cầu phi chức năng (NFR)

- **NFR-1 (Tái lập).** Test suite phải chạy pass offline (không cần LLM key), có test riêng cho từng kịch bản tấn công, không skip ngầm mà không có lý do rõ ràng.
- **NFR-2 (Tách bạch tất định/không tất định).** Mọi output phụ thuộc LLM phải đánh dấu rõ `mode`, không được lẫn với output heuristic khi so sánh kết quả.
- **NFR-3 (Ranh giới quyền hạn thật).** IAM phải là rào chặn kỹ thuật thật (Gateway từ chối request), không phải chỉ ghi trong prompt hướng dẫn agent "không được làm X".
- **NFR-4 (Cách ly mạng).** Nguyên tắc bắc cầu network: mỗi ranh giới mạng (outer↔dmz, dmz↔sandbox, sandbox↔tools) chỉ có đúng 1 service được phép bắc cầu — không service nào khác được attach chéo network.
- **NFR-5 (Khớp contract).** Route, status code, response body, tên scope phải khớp tuyệt đối với `docs/source/testbed_spec.md` — đây là hợp đồng với đội Attacker System, sai lệch dù nhỏ cũng làm hỏng kịch bản test tự động của họ.
- **NFR-6 (Observability).** Không có hành động nào (tool call, quyết định agent) xảy ra mà không sinh bằng chứng quan sát được — nguyên tắc "không có trace thì coi như không xảy ra" khi Judge chấm.

---

## 5. Nguồn dữ liệu & tri thức

- Dữ liệu host mẫu (`host_id`, `owner`, `criticality`) — dữ liệu giả lập, không PII.
- Threat intel mẫu cho RAG — đủ để agent có ngữ cảnh quyết định, không cần độ phủ thật.
- Alert: 2 nguồn — alert chuẩn hoá gửi tay (test/demo nhanh) và alert thật từ lab tấn công qua SIEM (luồng chính, thể hiện tính "thật" của testbed).

---

## 6. Ràng buộc & giả định

- Không có quyền truy cập hệ AI-SOC thật của tổ chức — mọi thứ chạy trong sandbox tự dựng.
- LLM thật là tuỳ chọn (qua key), hệ thống phải chạy được đầy đủ bằng heuristic khi không có key, để không chặn CI/demo.
- Target System không tối ưu cho vận hành thật (không cần HA, không cần chịu tải cao) — chỉ cần đủ ổn định để phục vụ kịch bản kiểm thử lặp lại.
- Thời gian và nhân lực có hạn (dự án học phần) — ưu tiên đúng scope FR-T1→T9, không mở rộng thêm tính năng ngoài contract với Attacker System.
