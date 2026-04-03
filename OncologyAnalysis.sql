-- ============================================================
-- PROJECT: Phase III Oncology Clinical Trial Data Analysis
-- AUTHOR: OLUSOLA CHIAMAKA
-- TOOL: PostgreSQL
-- ============================================================

-- ============================================================
--PILLAR 1: PATIENT RETENTION
-- ============================================================

-- Query 1: How many patients missed at least one visit?
select
	COUNT (DISTINCT patient_id) AS patients_with_missed_visits
FROM visits
WHERE visit_status = 'Missed';

--Query 2: Which visit (Baseline, Cycle 1, Cycle 2, etc.) has the highest number of missed appointments?
Select visit_name, count (*) as missed_visits
from visits
where visit_status = 'Missed'
Group by visit_name
Order by missed_visits desc
limit 1;

--Query 3: Which patients have missed 2 or more visits?
Select patient_id, count (*) as missed_visits
from visits
where visit_status = 'Missed'
Group by patient_id
having count (*) >= 2
order by missed_visits desc;

-- ============================================================
-- PILLAR 2: SAFETY MONITORING
-- ============================================================

--Query 4: How many adverse events occurred in each treatment arm?
select count (*) as number_of_adverse_events, patients.treatment_arm 
from adverse_events
join patients
on adverse_events.patient_id = patients.patient_id
group by patients.treatment_arm;

--Query 5: What are the top 5 most frequently reported adverse events?
select count (*) as MostFrequentAE, ae_term
from adverse_events
group by ae_term
order by MostFrequentAE desc
limit 5;

--Query 6: How many Grade 3 and Grade 4 adverse events occurred, and how are they distributed across treatment arms?
select count (*) as NoOfGrade3and4, adverse_events.ctcae_grade, treatment_arm
from adverse_events
join patients
on adverse_events.patient_id = patients.patient_id
where adverse_events.ctcae_grade in (3,4)
group by adverse_events.ctcae_grade,treatment_arm;

--Query 7: Which patients experienced a Serious Adverse Event (SAE)?
select patient_id, ae_term
from adverse_events
where serious_ae = true;
--additional information:
select patient_id, count (*) as severe_patients
from adverse_events
where serious_ae = true
group by patient_id
having count (*)>1
order by severe_patients desc; 

-- ============================================================
-- PILLAR 3: SITE PERFORMANCE 
-- ============================================================

--Query 8: How many patients did each site enroll vs their target enrollment?
select sites.site_name, count (*) as actual_enrollment, sites.target_enrollment
from patients
join sites
on patients.site_id = sites.site_id
group by sites.site_name, sites.target_enrollment;

--Query 9: Which site has the highest number of missed visits?
select sites.site_name, count (*) as Site_With_Most_missed_visits 
from sites
join patients on sites.site_id = patients.site_id
join visits on visits.patient_id = patients.patient_id
where visits.visit_status = 'Missed'
Group by sites.site_name
order by Site_With_Most_missed_visits desc
limit 10;

-- ============================================================
-- PILLAR 4: DATA_QUALITY
-- ============================================================

--Query 10: Which patients had a dose deviation flagged(I added additional context for better understanding that answers the why)?
select patient_id, deviation_flag, protocol_dose_mg, administered_dose_mg, deviation_reason 
from dosing
where deviation_flag = true; 

--Query 11: Which patients had their dose held, and what treatment arm are they in?
select patients.patient_id, patients.treatment_arm
from patients
join dosing
on patients.patient_id = dosing.patient_id
where dosing.dose_held = true                                                                 
