## VSOC-19 — RedTeamAI
**Tên đầy đủ:** AI Agent red-team tự động kiểm thử đối kháng chính hệ AI-SOC

**Thực trạng:** Hệ AI-SOC của Trung tâm An ninh mạng (VinSOC) X ngày càng phức tạp với nhiều agent LLM; bản thân chính các agent (prompt injection, jailbreak, đầu độc dữ liệu, lạm quyền) chưa được kiểm thử đối kháng với hệ thống.

**Vấn đề:** Xây AI Agent red-team tự động tấn công chính các agent phòng thủ AI-SOC: sinh và thử các kỹ thuật đối kháng (indirect prompt injection, jailbreak, vượt scope IAM, đầu độc RAG), đo mục tiêu có bị hijack/lộ dữ liệu/hành động sai không, rồi tổng hợp báo cáo điểm yếu kèm khuyến nghị và guardrails.

**Ràng buộc:** Chỉ tấn công các agent nội bộ trong môi trường mô phỏng/staging được cấp phép, tuyệt đối không phá hoại/thay đổi trạng thái hệ thống ngoài; hành động tấn công có tính phá hoại phải qua HITL duyệt; red-team agent least-privilege, không tự ý, được giới hạn phạm vi tấn công; grounded trên phản hồi thật của agent mục tiêu, chống bịa lỗ hổng; giảm false positive; kiểm soát chi phí/độ trễ và báo cáo bị lợi dụng; kiểm soát chi phí/độ trễ.

**Tech stack gợi ý:**
- LLM
- LangGraph/CrewAI
- Thư viện adversarial (garak/PyRIT) + custom attack tools qua MCP
- RAG kỹ thuật tấn công LLM Qdrant
- Kong Gateway kiểm soát scope
- Slack/Teams HITL
- FastAPI
- React/Next.js report
- Langfuse/LangSmith
- DeepEval/promptfoo
- Docker

**Yêu cầu đầu ra:**
- *Cơ bản:* Web app deploy, đăng nhập, ≥2 vai trò (Red-teamer, Approver); chọn agent mục tiêu nội bộ, chạy bộ tấn công đối kháng, báo cáo điểm yếu kèm bằng chứng, HITL duyệt các tấn công rủi ro, xử lý lỗi.
- *Nâng cao:* Multi-agent (Attack Planner + Executor + Evaluator); benchmark tỉ lệ tấn công thành công theo loại; trace; least-privilege qua Gateway; tối ưu chi phí/độ trễ và báo cáo, khép vòng với đội blue-team.

