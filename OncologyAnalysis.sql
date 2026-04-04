-- ============================================================
-- PROJECT: Phase III Oncology Clinical Trial Data Analysis
-- AUTHOR: OLUSOLA CHIAMAKA
-- TOOL: PostgreSQL
-- ============================================================

-- ============================================================
-- PILLAR 1: EXPLORATORY PATIENT ANALYSIS 
-- ============================================================

-- Query 1: Is there a difference in adverse event rates between male and female patients?
select count (*) as rate_of_adverse_events, p.sex
from patients p
join adverse_events ae
on p.patient_id = ae.patient_id
group by p.sex;

/* Findings: Male patients recorded 92 adverse events compared to 83 for female patients. Given that the trial enrolled 61 males 
and 59 females. This difference is marginally higher for males but not dramatically so. This might prompt further investigation
into whether specific adverse event types are more prevalent in one sex over the other, which could inform patient monitoring and 
supportive care strategies.*/

-- Query 2:  Do older patients (above a certain age) experience more Grade 3/4 adverse events than younger patients?
select 
	case
		when p.age < 60 then 'Under 60'
		when p.age between 60 and 69 then '60-69'
		else '70 and above'
	end as age_group,
	count (*) as severe_ae_count
from patients p
join adverse_events ae
on p.patient_id = ae.patient_id
where ae.ctcae_grade in (3,4)
group by age_group
order by severe_ae_count;

/* Findings: Patients aged 70 and above recorded the highest number of Grade 3 and Grade 4 adverse events at 23, closely followed 
by the 60-69 age group at 22. Patients under 60 recorded significantly fewer severe adverse events at just 7.
This is likely due to older patients experiencing more severe adverse events when undergoing chemotherapy as a result  of reduced
organ function and lower physiological reserves that come with age, making it harder for older patients to tolerate aggressive
treatment.*/

-- ============================================================
--PILLAR 2: PATIENT RETENTION
-- ============================================================

-- Query 3: How many patients missed at least one visit?
select
	COUNT (DISTINCT patient_id) AS patients_with_missed_visits
FROM visits
WHERE visit_status = 'Missed';

--Findings: 45 out of 120 enrolled patients (37.5%) missed at least one scheduled visit during the trial.
/*Implication: A missed visit rate of 37.5% is clinically significant. Missing visits means gaps in safety monitoring, potential
missed doses, and incomplete data collection, all of which could compromise the integrity of the trial and raise concerns
during regulatory review*/


--Query 4: Which visit (Baseline, Cycle 1, Cycle 2, etc.) has the highest number of missed appointments?
Select visit_name, count (*) as missed_visits
from visits
where visit_status = 'Missed'
Group by visit_name
Order by missed_visits desc
limit 1;

--Finding: Cycle 2 Day 1 had the highest number of missed visits, totalling 32. I wrote a query to find out why
select v.patient_id, v.visit_name, v.scheduled_date, ae.ae_term,  ae.ctcae_grade, ae.onset_date
from visits v
join adverse_events ae
on v.patient_id = ae.patient_id
where v.visit_status = 'Missed'
and v.visit_name = 'Cycle 2 Day 1'
and ae.onset_date between v.scheduled_date - interval '30 days' and v.scheduled_date + interval '30 days'
order by v.patient_id;

/*Findings: It turns out that almost all patients who missed their Cycle 2 Day 1 visit had at least one active adverse event
within 30 days of their scheduled appointment. Several had multiple Grade 3 and Grade 4 events occurring simultaneously. This 
confirms that missed visits at Cycle 2 were largely driven by adverse events rather than patient disengagement. This has
important implications for patient support strategies. Proactive check-ins and symptom management before scheduled visits
could help improve retention rates.*/

--Query 5: Which patients have missed 2 or more visits?
Select patient_id, count (*) as missed_visits
from visits
where visit_status = 'Missed'
Group by patient_id
having count (*) >= 2
order by missed_visits desc;

/* Findings: 7 patients missed 2 or more scheduled visits during the trial. This could be attributed to multiple reasons
including loss to follow-up, withdrawal due to adverse events, or patients being too unwell to attend.
Implication: Multiple missed visits per patient create significant data gaps that could affect the statistical validity 
of the trial. The clinical team should strengthen their patient follow-up protocols. Proactive check-ins between visits could 
help identify at-risk patients before they disengage completely.*/

-- ============================================================
-- PILLAR 2: SAFETY MONITORING
-- ============================================================

--Query 6: How many adverse events occurred in each treatment arm?
select count (*) as number_of_adverse_events, patients.treatment_arm, adverse_events.related_to_drug 
from adverse_events
join patients
on adverse_events.patient_id = patients.patient_id
where adverse_events.related_to_drug = 'Yes'
group by patients.treatment_arm, adverse_events.related_to_drug;

/*Findings: The investigational arm recorded 92 total adverse events compared to 83 in the control arm. When filtered for 
drug-related events only, the numbers were 59 vs 46 respectively.
Implication: While the investigational arm shows a higher number of drug-related adverse events, the difference alone is not 
sufficient to conclude the drug is more dangerous. Further investigation into the severity and nature of these events is 
required, which is explored in subsequent queries.*/

--Query 7: What are the top 5 most frequently reported adverse events?
select count (*) as MostFrequentAE, ae_term
from adverse_events
group by ae_term
order by MostFrequentAE desc
limit 5;

/*Findings: The top 5 most frequently reported adverse events were  Alopecia (26), Peripheral Neuropathy (23), Fatigue (21), 
Rash (18) and Neutropenia (12).*/

--Query 8: How many Grade 3 and Grade 4 adverse events occurred, and how are they distributed across treatment arms?
select count (*) as NoOfGrade3and4, adverse_events.ctcae_grade, treatment_arm
from adverse_events
join patients
on adverse_events.patient_id = patients.patient_id
where adverse_events.ctcae_grade in (3,4)
group by adverse_events.ctcae_grade,treatment_arm;

/*Findings: The investigational arm recorded 25 Grade 3 and 2 Grade 4 adverse events. The control arm recorded 13 Grade 3
and 12 Grade 4 adverse events.
Implications: While the investigational arm has more Grade 3 events, the control arm has significantly more Grade 4 life-threatening events.
This is a notable safety signal suggesting the standard treatment may carry a higher risk of life-threatening complications.
This finding would be flagged for urgent review by the Data Safety Monitoring Board*/.

--Query 9: Which patients experienced a Serious Adverse Event (SAE)?
select patient_id, ae_term
from adverse_events
where serious_ae = true;
--Which patients had more than one SAE? 
select patient_id, count (*) as severe_patients
from adverse_events
where serious_ae = true
group by patient_id
having count (*)>1
order by severe_patients desc; 

/*Findings: Multiple patients experienced Serious Adverse Events during the trial. 8 patients had more than one SAE, with Patient 
50 recording the highest number at 4 SAEs, this patient subsequently died during the trial. Patients 7, 10, 27, 85, and 100 each
recorded 3 SAEs
Implications:  In a real trial, these patients would be immediately flagged for urgent medical review, and their cases would be 
escalated to the Data Safety Monitoring Board. The death of Patient 50 following 4 serious adverse events would trigger a full 
safety investigation.*/

-- ============================================================
-- PILLAR 3: SITE PERFORMANCE 
-- ============================================================

--Query 10: How many patients did each site enroll vs their target enrollment?
select sites.site_name, count (*) as actual_enrollment, sites.target_enrollment
from patients
join sites
on patients.site_id = sites.site_id
group by sites.site_name, sites.target_enrollment;

/*Findings: All 8 research sites met their target enrollment exactly. Enrollment ranged from 10 patients at Atlantic Research 
Consortium to 20 patients at Memorial Cancer Center. Full enrollment across all sites is a positive operational outcome. 
In a real trial, it is rare for every site to hit its exact target; this would indicate strong site management and effective 
patient recruitment strategies across all locations.*/

--Query 11: Which site has the highest number of missed visits?
select sites.site_name, count (*) as Site_With_Most_missed_visits 
from sites
join patients on sites.site_id = patients.site_id
join visits on visits.patient_id = patients.patient_id
where visits.visit_status = 'Missed'
Group by sites.site_name
order by Site_With_Most_missed_visits desc
limit 10;

/* Findings: Memorial Cancer Center recorded the highest number of missed visits at 13, followed by Pacific Northwest Cancer
Group at 9. Atlantic Research Consortium had the fewest missed visits at 3.  Memorial Cancer Center's high missed visit count
is partly explained by having the largest patient enrollment at 20 patients. However, the rate of missed visits still requires 
attention.*/ 

-- ============================================================
-- PILLAR 4: DATA_QUALITY
-- ============================================================

--Query 12: Which patients had a dose deviation flagged?(I added additional context for better understanding that answers the why)
select patient_id, deviation_flag, protocol_dose_mg, administered_dose_mg, deviation_reason 
from dosing
where deviation_flag = true; 

/* Findings: 12 patients had dose deviations flagged during the trial. All deviations were due to the same reason: a 25% dose 
reduction following a Grade 3 adverse event. Protocol doses ranged from 137mg to 304mg, depending on the patient's BSA and 
treatment arm.*/

--Query 13: Which patients had their dose held, and what treatment arm are they in?
select patients.patient_id, patients.treatment_arm
from patients
join dosing
on patients.patient_id = dosing.patient_id
where dosing.dose_held = true                                                                 

/* Findings: Based on the available data, Patient 7 from the Investigational arm had doses held during the trial. Dose holds 
typically occur when a patient's safety profile makes it too risky to administer the next dose.*/