-- Target System — HostRegistry schema (Postgres)
-- Chỉ dùng cho HostRegistry. Postgres của Attacker System (run/finding/audit) là instance riêng,
-- ngoài repo này — xem testbed_spec.md §8.

CREATE TABLE IF NOT EXISTS hosts (
    host_id      TEXT PRIMARY KEY,
    owner        TEXT NOT NULL,
    criticality  TEXT NOT NULL CHECK (criticality IN ('low', 'medium', 'high', 'critical')),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Seed 10 host bắt buộc (docs/04-technical-design.md mục 3.1) — chạy 1 lần lúc migrate,
-- KHÔNG hardcode lại trong code Python.
INSERT INTO hosts (host_id, owner, criticality) VALUES
    ('dvwa-host', 'blue-team-1', 'high'),
    ('host-001', 'blue-team-1', 'low'),
    ('host-002', 'blue-team-1', 'medium'),
    ('host-003', 'blue-team-2', 'medium'),
    ('host-010', 'blue-team-2', 'high'),
    ('host-042', 'blue-team-2', 'critical'),
    ('host-099', 'blue-team-3', 'low'),
    ('host-100', 'blue-team-3', 'medium'),
    ('wazuh-manager', 'infra', 'critical'),
    ('firewall-01', 'infra', 'critical')
ON CONFLICT (host_id) DO NOTHING;
