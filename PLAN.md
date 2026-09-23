# Target System — Kế hoạch xây dựng chuẩn chỉnh

> Mục tiêu: dựng đúng scope theo `docs/source/testbed_spec.md`/PRD/TRD, sạch tên gọi ngay từ đầu — không phải sửa lại sau.

## 0. Vì sao đặt tên chuẩn ngay từ đầu

Hệ thống có 2 lớp (agentic + ingest & lab tấn công) do 2 người phụ trách song song — nếu không thống nhất quy ước tên gọi ngay từ commit đầu tiên, container/network/volume rất dễ bị đặt tên lệch nhau khi ghép lại. Chốt quy ước ở mục 1 trước khi viết dòng code đầu tiên.

## 1. Quy ước tên gọi chuẩn (áp dụng NGAY từ commit đầu tiên)

| Thứ | Tên chuẩn | Ghi chú |
|---|---|---|
| Compose project | `targetsystem` | `name: targetsystem` trong `docker-compose.yml` |
| Prefix container/volume/network | `ts-` (Target System) | Không dùng tên nhánh cá nhân (không `vg-`, không `swarm-` lẫn lộn) |
| Lớp xử lý agentic | thư mục `core/` — services: `agent-a`, `agent-b`, `gateway`, `host-registry`, `rag`, `tools` | Giữ tên service ngắn gọn, không gắn brand cá nhân |
| Lớp sinh alert thật | thư mục `ingest/` — services: `firewall`, `dvwa`, `wazuh-manager`, `wazuh-indexer`, `wazuh-dashboard`, `ingest-api`, `dispatcher`, `attacker`, `tailscale` | |
| Network | `ts-outer-net`, `ts-dmz-net`, `ts-sandbox-net`, `ts-tools-net` | Đồng bộ prefix cho cả 4, không network nào thiếu prefix |
| Volume | `ts_pgdata`, `ts_qdrantdata`, `ts_wazuh_*`, `ts_tailscale_state`, `ts_dvwa_apache_logs` | |
| Tài liệu | gọi theo vai trò: "lớp agentic", "lớp ingest & lab tấn công" — không gắn tên riêng nào cả | |

## 2. Cấu trúc thư mục đề xuất

```
Target System/
├── PLAN.md                    ← file này
├── docker-compose.yml
├── docker-compose.patched.yml
├── docker-compose.unpatched.yml
├── .env.example
├── core/                      ← lớp agentic (agent-a, agent-b, gateway, host-registry, rag, tools, common)
│   ├── agent_a/
│   ├── agent_b/
│   ├── gateway/
│   ├── host_registry/
│   ├── rag/
│   ├── tools/
│   └── common/                ← tracing, IAM helpers dùng chung
├── ingest/                    ← lớp ingest & lab tấn công (firewall, dvwa, wazuh, ingest-api, dispatcher, attacker, tailscale)
│   ├── firewall/
│   ├── ingest-api/
│   ├── dispatcher/
│   └── wazuh/
├── db/
│   └── schema.sql
├── tests/
│   ├── unit/
│   └── integration/
└── docs/
    ├── 00-tong-quan.md
    ├── 01-requirements.md
    ├── 02-design.md
    ├── 03-checklist.md
    └── runbook.md
```

## 3. Thứ tự build (theo phụ thuộc, không theo cảm hứng)

1. **Nền tảng:** `docker-compose.yml` khung (network + Postgres) → không có service nghiệp vụ nào chạy được nếu bước này sai.
2. **Lớp agentic (core/):** HostRegistry → RAG → Agent A → Agent B → Gateway (IAM per-identity) → Tools. Đây là phần Claude Code hỗ trợ nhanh nhất — code có khuôn mẫu rõ theo contract đã biết (`docs/source/testbed_spec.md`).
3. **Test lớp agentic:** viết test suite đầy đủ (unit + integration), chạy pass trước khi đụng vào lớp ingest.
4. **2 biến thể patched/unpatched:** chữ ký A2A + bọc untrusted-data — làm ngay sau khi lớp agentic ổn định, đừng để cuối.
5. **Lớp ingest & lab tấn công:** firewall → DVWA → Wazuh Manager/Indexer/Dashboard → Ingest API → dispatcher → Attacker/Tailscale. Đây là phần tốn thời gian thật (chạy-và-chờ, không compress được nhiều bằng AI).
6. **Nối 2 lớp:** dispatcher → Agent A, verify bằng 1 cuộc tấn công DVWA thật → xem alert đi hết pipeline.
7. **7 kịch bản tấn công:** wire + test lại từng kịch bản, đối chiếu đúng `docs/source/testbed_spec.md`.
8. **Docs:** cập nhật `docs/03-checklist.md` theo đúng trạng thái code thật, giữ `01-requirements.md`/`02-design.md` làm đích tham chiếu.

## 4. Mốc thời gian ước tính (có Claude Code hỗ trợ, làm part-time sinh viên)

| Giai đoạn | Thời gian |
|---|---|
| Bước 1–4 (lớp agentic hoàn chỉnh + test pass) | ~4–6 ngày |
| Bước 5–6 (lớp ingest + lab tấn công + nối 2 lớp) | ~5–7 ngày |
| Bước 7 (7 kịch bản tấn công + verify) | ~2–3 ngày |
| Bước 8 (docs) | ~1 ngày |
| **Tổng** | **~2.5–3.5 tuần** |

## 5. Điều kiện dừng / rollback

- Nếu quá 1 tuần mà Bước 1–4 chưa xong → tiến độ đang chậm hơn dự kiến, báo sớm với team lead để cân nhắc lại deadline hoặc chia việc.
