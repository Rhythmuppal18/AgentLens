BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "debug_room" (
    "id" bigserial PRIMARY KEY,
    "roomCode" text NOT NULL,
    "name" text NOT NULL,
    "createdBy" text NOT NULL,
    "ingestTokenHash" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "currentSequenceNumber" bigint NOT NULL DEFAULT 0,
    "isActive" boolean NOT NULL DEFAULT true
);

-- Indexes
CREATE UNIQUE INDEX "debug_room_code_unique_idx" ON "debug_room" USING btree ("roomCode");
CREATE INDEX "debug_room_ingest_token_idx" ON "debug_room" USING btree ("ingestTokenHash");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "investigation_note" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "roomCode" text NOT NULL,
    "findingId" bigint,
    "authorName" text NOT NULL,
    "content" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "investigation_note_room_idx" ON "investigation_note" USING btree ("roomCode");
CREATE INDEX "investigation_note_finding_idx" ON "investigation_note" USING btree ("findingId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room_finding" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "roomCode" text NOT NULL,
    "traceId" text NOT NULL,
    "spanId" text,
    "spanName" text,
    "ruleType" text NOT NULL,
    "severity" text NOT NULL,
    "summary" text NOT NULL,
    "evidenceSummary" text NOT NULL,
    "evidenceDataJson" text,
    "detectedAt" timestamp without time zone NOT NULL,
    "isSample" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE INDEX "room_finding_room_code_idx" ON "room_finding" USING btree ("roomCode");
CREATE INDEX "room_finding_trace_idx" ON "room_finding" USING btree ("roomCode", "traceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room_participant" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "roomCode" text NOT NULL,
    "participantName" text NOT NULL,
    "deviceId" text NOT NULL,
    "participantTokenHash" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL,
    "lastSeenAt" timestamp without time zone NOT NULL,
    "isOnline" boolean NOT NULL DEFAULT true
);

-- Indexes
CREATE INDEX "room_participant_room_code_idx" ON "room_participant" USING btree ("roomCode");
CREATE INDEX "room_participant_token_idx" ON "room_participant" USING btree ("participantTokenHash");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room_span" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "roomCode" text NOT NULL,
    "traceId" text NOT NULL,
    "spanId" text NOT NULL,
    "parentSpanId" text,
    "name" text NOT NULL,
    "spanType" text NOT NULL,
    "status" text NOT NULL,
    "durationMs" bigint NOT NULL,
    "inputPayloadJson" text,
    "outputPayloadJson" text,
    "errorMessage" text,
    "errorType" text,
    "errorStack" text,
    "startTime" timestamp without time zone NOT NULL,
    "endTime" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "room_span_room_span_idx" ON "room_span" USING btree ("roomCode", "spanId");
CREATE INDEX "room_span_trace_idx" ON "room_span" USING btree ("roomCode", "traceId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room_trace" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "roomCode" text NOT NULL,
    "traceId" text NOT NULL,
    "agentName" text NOT NULL,
    "status" text NOT NULL,
    "durationMs" bigint NOT NULL,
    "totalTokens" bigint NOT NULL DEFAULT 0,
    "startTime" timestamp without time zone NOT NULL,
    "endTime" timestamp without time zone,
    "isSample" boolean NOT NULL DEFAULT false
);

-- Indexes
CREATE UNIQUE INDEX "room_trace_room_trace_idx" ON "room_trace" USING btree ("roomCode", "traceId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "investigation_note"
    ADD CONSTRAINT "investigation_note_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "debug_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "room_finding"
    ADD CONSTRAINT "room_finding_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "debug_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "room_participant"
    ADD CONSTRAINT "room_participant_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "debug_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "room_span"
    ADD CONSTRAINT "room_span_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "debug_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "room_trace"
    ADD CONSTRAINT "room_trace_fk_0"
    FOREIGN KEY("roomId")
    REFERENCES "debug_room"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR agentlens_hackathon
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('agentlens_hackathon', '20261121230529728', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261121230529728', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20261015164015382', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015164015382', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
