-- ============================================================
-- PROJECT: Phase III Oncology Clinical Trial Data Analysis
-- Author: [Your Name]
-- Tool: PostgreSQL
-- Description: Schema for a simulated Phase III randomized 
--              controlled trial comparing a novel chemotherapy 
--              agent vs. standard of care in non-small cell 
--              lung cancer (NSCLC) patients.
--
-- Tables:
--   1. sites          - Research sites participating in the trial
--   2. patients       - Enrolled patient demographics & treatment arm
--   3. visits         - Scheduled vs. actual patient visit records
--   4. adverse_events - Safety events using CTCAE grading
--   5. dosing         - Dose administration records & deviations
--   6. disposition    - Patient trial status (active, withdrew, etc.)
-- ============================================================


-- ============================================================
-- TABLE 1: SITES
-- Represents the hospitals/research centers running the trial.
-- In a real trial, performance varies widely by site — 
-- identifying underperforming sites is a key operational task.
-- ============================================================

CREATE TABLE sites (
    site_id       SERIAL PRIMARY KEY,
    site_name     VARCHAR(100) NOT NULL,
    country       VARCHAR(50)  NOT NULL,
    region        VARCHAR(50),                      -- e.g., Northeast, Midwest
    principal_investigator VARCHAR(100),            -- Lead doctor at the site
    activated_date DATE NOT NULL,                   -- When site was approved to enroll
    target_enrollment INT NOT NULL                  -- How many patients the site is expected to enroll
);


-- ============================================================
-- TABLE 2: PATIENTS
-- Core patient table. Each patient is randomized to either
-- the investigational arm or the control (standard of care).
-- BSA (body surface area) is included because chemotherapy 
-- dosing is calculated from it — important for deviation checks.
-- ============================================================

CREATE TABLE patients (
    patient_id      SERIAL PRIMARY KEY,
    site_id         INT REFERENCES sites(site_id),
    age             INT NOT NULL,
    sex             VARCHAR(10) CHECK (sex IN ('Male', 'Female', 'Other')),
    race            VARCHAR(50),
    diagnosis       VARCHAR(100) NOT NULL,          -- e.g., 'NSCLC - Stage IIIB'
    ecog_score      INT CHECK (ecog_score BETWEEN 0 AND 5), -- Performance status (0=fully active, 5=dead)
    treatment_arm   VARCHAR(20) CHECK (treatment_arm IN ('Investigational', 'Control')),
    enrollment_date DATE NOT NULL,
    bsa             NUMERIC(4,2),                   -- Body Surface Area in m² (used for dose calculation)
    weight_kg       NUMERIC(5,1),
    height_cm       NUMERIC(5,1)
);


-- ============================================================
-- TABLE 3: VISITS
-- Every patient has a schedule of visits (e.g., Week 1, Week 3).
-- Missed or late visits are a major retention and data quality issue.
-- We track both the scheduled date and actual date to identify
-- missed visits and protocol deviations.
-- ============================================================

CREATE TABLE visits (
    visit_id        SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    visit_number    INT NOT NULL,                   -- e.g., 1, 2, 3 (visit sequence)
    visit_name      VARCHAR(50),                    -- e.g., 'Baseline', 'Cycle 1 Day 1', 'Week 12'
    scheduled_date  DATE NOT NULL,
    actual_date     DATE,                           -- NULL if visit was missed
    visit_status    VARCHAR(20) CHECK (visit_status IN ('Completed', 'Missed', 'Rescheduled', 'Withdrawn')),
    notes           TEXT
);


-- ============================================================
-- TABLE 4: ADVERSE EVENTS
-- Safety is the most critical aspect of any clinical trial.
-- CTCAE (Common Terminology Criteria for Adverse Events) is the
-- real-world standard used to grade severity (1=mild, 5=death).
-- Tracking whether an event is related to the study drug is key
-- for regulatory submissions.
-- ============================================================

CREATE TABLE adverse_events (
    ae_id           SERIAL PRIMARY KEY,
    patient_id      INT REFERENCES patients(patient_id),
    ae_term         VARCHAR(150) NOT NULL,          -- e.g., 'Nausea', 'Neutropenia', 'Fatigue'
    ae_category     VARCHAR(100),                   -- System Organ Class e.g., 'Gastrointestinal'
    ctcae_grade     INT CHECK (ctcae_grade BETWEEN 1 AND 5), -- 1=Mild, 2=Moderate, 3=Severe, 4=Life-threatening, 5=Death
    onset_date      DATE NOT NULL,
    resolution_date DATE,                           -- NULL if ongoing
    related_to_drug VARCHAR(10) CHECK (related_to_drug IN ('Yes', 'No', 'Possible', 'Unlikely')),
    serious_ae      BOOLEAN DEFAULT FALSE,          -- SAE = requires hospitalization or life-threatening
    action_taken    VARCHAR(50)                     -- e.g., 'Dose Reduced', 'Drug Withdrawn', 'None'
);


-- ============================================================
-- TABLE 5: DOSING
-- Records every dose given to a patient.
-- Protocol specifies an expected dose based on BSA.
-- Deviations (giving too much or too little) are a compliance issue.
-- This table lets us flag patients who received incorrect doses.
-- ============================================================

CREATE TABLE dosing (
    dose_id             SERIAL PRIMARY KEY,
    patient_id          INT REFERENCES patients(patient_id),
    visit_id            INT REFERENCES visits(visit_id),
    cycle_number        INT NOT NULL,               -- Treatment cycle (e.g., Cycle 1, Cycle 2)
    day_in_cycle        INT NOT NULL,               -- Day within that cycle (e.g., Day 1, Day 8)
    protocol_dose_mg    NUMERIC(7,2) NOT NULL,      -- What the protocol said the patient should receive
    administered_dose_mg NUMERIC(7,2),              -- What was actually given (NULL if dose was held)
    dose_held           BOOLEAN DEFAULT FALSE,      -- Was the dose skipped?
    deviation_flag      BOOLEAN DEFAULT FALSE,      -- Did the dose deviate >10% from protocol?
    deviation_reason    TEXT                        -- Reason if flagged
);


-- ============================================================
-- TABLE 6: DISPOSITION
-- Tracks the final/current status of each patient in the trial.
-- Dropout reasons are critical for understanding retention issues
-- and are required in final trial reporting to regulators (FDA/EMA).
-- ============================================================

CREATE TABLE disposition (
    disposition_id      SERIAL PRIMARY KEY,
    patient_id          INT REFERENCES patients(patient_id) UNIQUE, -- One record per patient
    current_status      VARCHAR(30) CHECK (current_status IN (
                            'Active',
                            'Completed',
                            'Withdrew - Adverse Event',
                            'Withdrew - Patient Decision',
                            'Withdrew - Physician Decision',
                            'Lost to Follow-Up',
                            'Deceased',
                            'Screen Failure'
                        )),
    status_date         DATE NOT NULL,              -- Date the status was last updated
    completion_reason   TEXT,                       -- Additional context
    study_completion    BOOLEAN DEFAULT FALSE       -- Did patient complete all required visits?
);
