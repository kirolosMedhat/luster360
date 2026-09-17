-- ==============================================================================
-- LUSTER 360 PLATFORM — ROLES & ADMIN CONSOLE SCHEMA MIGRATION
-- Migration: 20260916000001_roles_and_admin_schema.sql
-- Description: Extends user_role enum to support granular RBAC:
--              super_admin, company_admin, operator, viewer.
--              Adds helper authorization functions and indexes for admin telemetry.
-- ==============================================================================

-- 1. Extend user_role ENUM
DO 
BEGIN
    ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'super_admin';
    ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'company_admin';
    ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'operator';
    ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'viewer';
EXCEPTION
    WHEN duplicate_object THEN null;
END ;

-- 2. Ensure profiles table default and validation
ALTER TABLE profiles 
    ALTER COLUMN role SET DEFAULT 'operator'::user_role;

-- 3. Security Helper: is_admin check for RLS
CREATE OR REPLACE FUNCTION is_admin(user_id UUID)
RETURNS BOOLEAN AS 
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = user_id
        AND LOWER(role::text) IN ('super_admin', 'company_admin', 'admin', 'owner')
    );
END;
 LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Security Helper: is_super_admin check for RLS
CREATE OR REPLACE FUNCTION is_super_admin(user_id UUID)
RETURNS BOOLEAN AS 
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = user_id
        AND LOWER(role::text) IN ('super_admin', 'owner')
    );
END;
 LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Guarantee Unique Index on videos short_code
CREATE UNIQUE INDEX IF NOT EXISTS idx_videos_short_code_unique ON videos(short_code);

-- 6. Performance Index for Fleet Device Heartbeats and Telemetry
CREATE INDEX IF NOT EXISTS idx_devices_last_heartbeat ON devices(last_heartbeat DESC);
CREATE INDEX IF NOT EXISTS idx_devices_status ON devices(status);
CREATE INDEX IF NOT EXISTS idx_events_status_date ON events(status, event_date DESC);
