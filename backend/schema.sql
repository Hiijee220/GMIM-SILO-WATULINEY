-- PostgreSQL schema for private backend ONLY. Never run this on GitHub Pages.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE roles (id smallserial PRIMARY KEY, code text UNIQUE NOT NULL CHECK(code IN ('super_admin','admin','pastor','treasurer','column_leader','viewer')));
INSERT INTO roles(code) VALUES ('super_admin'),('admin'),('pastor'),('treasurer'),('column_leader'),('viewer');
CREATE TABLE church_columns (id smallserial PRIMARY KEY CHECK(id BETWEEN 1 AND 16), name text NOT NULL, worship_day text, worship_time time, worship_place text, public_note text);
INSERT INTO church_columns(id,name) SELECT i,'Kolom '||i FROM generate_series(1,16) i;
CREATE TABLE staff_users (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), email text UNIQUE NOT NULL, password_hash text NOT NULL, role_id smallint NOT NULL REFERENCES roles(id), column_id smallint REFERENCES church_columns(id), active boolean NOT NULL DEFAULT true, created_at timestamptz NOT NULL DEFAULT now(), CHECK(column_id IS NULL OR column_id BETWEEN 1 AND 16));
CREATE TABLE families (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), family_code text UNIQUE NOT NULL, head_name text NOT NULL, address text, phone text, column_id smallint NOT NULL REFERENCES church_columns(id), created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE members (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), family_id uuid NOT NULL REFERENCES families(id) ON DELETE RESTRICT, full_name text NOT NULL, birth_date date, sex text CHECK(sex IN ('L','P')), member_status text, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now());
CREATE TABLE financial_accounts (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), name text NOT NULL, active boolean NOT NULL DEFAULT true);
CREATE TABLE cash_transactions (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), account_id uuid NOT NULL REFERENCES financial_accounts(id), transaction_date date NOT NULL, direction text NOT NULL CHECK(direction IN ('income','expense')), amount numeric(15,2) NOT NULL CHECK(amount > 0), category text NOT NULL, description text, recorded_by uuid NOT NULL REFERENCES staff_users(id), created_at timestamptz NOT NULL DEFAULT now(), voided_at timestamptz, void_reason text);
CREATE TABLE announcements (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), title text NOT NULL, body text NOT NULL, is_public boolean NOT NULL DEFAULT false, published_at timestamptz, created_by uuid REFERENCES staff_users(id));
CREATE TABLE audit_logs (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, actor_id uuid REFERENCES staff_users(id), action text NOT NULL, entity_type text NOT NULL, entity_id text, occurred_at timestamptz NOT NULL DEFAULT now(), metadata jsonb NOT NULL DEFAULT '{}'::jsonb);
CREATE INDEX families_column_idx ON families(column_id);
CREATE INDEX members_family_idx ON members(family_id);
CREATE INDEX cash_account_date_idx ON cash_transactions(account_id,transaction_date);
-- Enforce authorization, scoped column access, session validation and audit logging in the backend.
-- Do not expose tables directly to unauthenticated browser clients.
