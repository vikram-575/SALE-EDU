-- =============================================================================
-- EDUCATESETU TELEGRAM PLATFORM 2.0 -- SUPABASE POSTGRESQL DDL
-- =============================================================================

-- 1. TELEGRAM BOTS
CREATE TABLE IF NOT EXISTS "telegram_bots" (
  "id" TEXT PRIMARY KEY,
  "botName" TEXT NOT NULL,
  "botUsername" TEXT NOT NULL,
  "botToken" TEXT NOT NULL,
  "webhookSecretToken" TEXT,
  "environment" TEXT DEFAULT 'PRODUCTION',
  "status" TEXT DEFAULT 'ACTIVE',
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 2. TELEGRAM USERS / IDENTITIES
CREATE TABLE IF NOT EXISTS "telegram_users" (
  "id" TEXT PRIMARY KEY,
  "telegramUserId" TEXT UNIQUE NOT NULL,
  "telegramChatId" TEXT NOT NULL,
  "username" TEXT,
  "firstName" TEXT,
  "lastName" TEXT,
  "phone" TEXT,
  "role" TEXT DEFAULT 'PROSPECT', -- PROSPECT, SCHOOL_ADMIN, PRINCIPAL, TEACHER, PARENT, STUDENT
  "schoolId" TEXT,
  "leadId" TEXT,
  "customerId" TEXT,
  "isOptedOut" BOOLEAN DEFAULT FALSE,
  "optOutAt" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 3. EXTEND TelegramConversation TABLE
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "context" TEXT DEFAULT 'SALES'; -- SALES vs SCHOOL
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "schoolId" TEXT;
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "customerId" TEXT;
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "priority" TEXT DEFAULT 'NORMAL'; -- URGENT, HIGH, NORMAL, LOW
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "intentCategory" TEXT DEFAULT 'UNKNOWN'; -- PRICING, DEMO_REQUEST, TRIAL_REQUEST, COMPLAINT, SUPPORT, INTERESTED, NOT_INTERESTED, NEGOTIATION
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "aiSummary" TEXT;
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "isArchived" BOOLEAN DEFAULT FALSE;
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "lastAgentId" TEXT;
ALTER TABLE "TelegramConversation" ADD COLUMN IF NOT EXISTS "doNotContact" BOOLEAN DEFAULT FALSE;

-- 4. EXTEND TelegramMessage TABLE
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "messageType" TEXT DEFAULT 'TEXT'; -- TEXT, IMAGE, DOCUMENT, VIDEO, AUDIO, VOICE, LOCATION, LINK, INLINE_KEYBOARD
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "attachmentUrl" TEXT;
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "attachmentMetadata" JSONB;
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "deliveryStatus" TEXT DEFAULT 'DELIVERED'; -- QUEUED, SENDING, SENT, DELIVERED, FAILED, RETRYING
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "retryCount" INT DEFAULT 0;
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "errorMessage" TEXT;
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "idempotencyKey" TEXT UNIQUE;
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "replyToMessageId" TEXT;
ALTER TABLE "TelegramMessage" ADD COLUMN IF NOT EXISTS "rawMetadata" JSONB;

-- 5. TELEGRAM MESSAGE TEMPLATES
CREATE TABLE IF NOT EXISTS "telegram_templates" (
  "id" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "category" TEXT NOT NULL, -- SALES, DEMO, TRIAL, CUSTOMER, SCHOOL, PARENT, TEACHER, STUDENT, PAYMENT, REMINDER, ANNOUNCEMENT, EMERGENCY
  "content" TEXT NOT NULL,
  "variables" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "status" TEXT DEFAULT 'ACTIVE',
  "createdBy" TEXT,
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 6. TELEGRAM AUTOMATIONS
CREATE TABLE IF NOT EXISTS "telegram_automations" (
  "id" TEXT PRIMARY KEY,
  "name" TEXT NOT NULL,
  "triggerEvent" TEXT NOT NULL, -- LEAD_CREATED, DEMO_COMPLETED, TRIAL_STARTED, TRIAL_EXPIRING_3DAYS, LEAD_WON, SCHOOL_ONBOARDED, ATTENDANCE_MARKED
  "delayMinutes" INT DEFAULT 0,
  "templateId" TEXT REFERENCES "telegram_templates"("id"),
  "conditions" JSONB,
  "isEnabled" BOOLEAN DEFAULT TRUE,
  "maxSends" INT DEFAULT 1,
  "quietHoursStart" TEXT DEFAULT '22:00',
  "quietHoursEnd" TEXT DEFAULT '07:00',
  "timezone" TEXT DEFAULT 'Asia/Kolkata',
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 7. TELEGRAM EVENTS QUEUE
CREATE TABLE IF NOT EXISTS "telegram_events" (
  "id" TEXT PRIMARY KEY,
  "eventType" TEXT NOT NULL,
  "schoolId" TEXT,
  "leadId" TEXT,
  "customerId" TEXT,
  "recipientRole" TEXT,
  "recipientChatId" TEXT,
  "payload" JSONB,
  "status" TEXT DEFAULT 'PENDING', -- PENDING, PROCESSED, FAILED
  "processedAt" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- 8. TELEGRAM AUDIT LOGS
CREATE TABLE IF NOT EXISTS "telegram_audit_logs" (
  "id" TEXT PRIMARY KEY,
  "actorId" TEXT,
  "actorRole" TEXT,
  "action" TEXT NOT NULL, -- CONVERSATION_LINKED, CONVERSATION_UNLINKED, MANUAL_LEAD_CREATED, OPT_OUT, AI_REPLY_APPROVED, AUTOMATION_TRIGGERED, MESSAGE_SENT, MESSAGE_BLOCKED
  "entityType" TEXT NOT NULL,
  "entityId" TEXT NOT NULL,
  "metadata" JSONB,
  "timestamp" TIMESTAMPTZ DEFAULT NOW()
);

-- 9. TELEGRAM HEALTH & DIAGNOSTIC LOGS
CREATE TABLE IF NOT EXISTS "telegram_health_logs" (
  "id" TEXT PRIMARY KEY,
  "webhookLatencyMs" INT,
  "apiStatus" TEXT DEFAULT 'HEALTHY',
  "queueLength" INT DEFAULT 0,
  "failedCount" INT DEFAULT 0,
  "lastE2eTestAt" TIMESTAMPTZ,
  "lastE2eTestResult" TEXT DEFAULT 'PASS',
  "timestamp" TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial default message templates
INSERT INTO "telegram_templates" ("id", "name", "category", "content", "variables", "status")
VALUES
('tpl_sales_intro', 'EducateSetu ERP Intro', 'SALES', 'Hello {{contact_name}}, welcome to EducateSetu! We empower schools with AI report cards, automated fee collection, and parent app integration. Would you like a quick 10-min live demo?', ARRAY['contact_name'], 'ACTIVE'),
('tpl_demo_scheduled', 'Demo Booking Confirmation', 'DEMO', 'Dear {{contact_name}}, your EducateSetu ERP live demo is scheduled for {{demo_date}} at {{demo_time}}. Demo Link: https://meet.educatesetu.com/demo', ARRAY['contact_name', 'demo_date', 'demo_time'], 'ACTIVE'),
('tpl_trial_onboarding', 'Trial Account Ready', 'TRIAL', 'Congratulations {{school_name}}! Your 14-day full access trial for EducateSetu is active. Log in at: https://app.educatesetu.com using username: {{username}}', ARRAY['school_name', 'username'], 'ACTIVE'),
('tpl_trial_reminder', 'Trial Expiring Notice', 'TRIAL', 'Hi {{contact_name}}, your EducateSetu trial for {{school_name}} ends on {{trial_end_date}}. Upgrade now to keep fee collection active: https://app.educatesetu.com/upgrade', ARRAY['contact_name', 'school_name', 'trial_end_date'], 'ACTIVE'),
('tpl_parent_attendance', 'Daily Attendance Alert', 'PARENT', 'Dear Parent, {{student_name}} has been marked PRESENT at {{school_name}} today at {{checkin_time}}.', ARRAY['student_name', 'school_name', 'checkin_time'], 'ACTIVE')
ON CONFLICT ("id") DO NOTHING;
