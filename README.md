Phase III Oncology Clinical Trial — SQL Data Analysis

Project Overview
This project simulates a Phase III randomized controlled clinical trial for Non-Small Cell Lung Cancer (NSCLC). Using PostgreSQL, I analyzed data across 120 patients, 8 research sites and 6 interconnected tables to uncover insights that would directly impact trial operations and patient safety. The analysis covers five key areas: exploratory clinical analysis, patient retention, safety monitoring, site performance and data quality, the same pillars that clinical data teams track in real oncology trials.

Tools Used
- PostgreSQL — database and query writing
- pgAdmin — visual database management
- VS Code — writing and formatting SQL files
- GitHub — version control and project hosting
- Dataset — simulated using AI assistance to reflect realistic Phase III oncology trial data

Database Structure
The database contains 6 interconnected tables:
- sites — 8 research centers participating in the trial
- patients — 120 enrolled patients with demographics and treatment arm
- visits — scheduled vs actual visit records per patient
- adverse_events — safety events using real CTCAE grading
- dosing — dose administration records and protocol deviations
- disposition — final trial status for each patient

 
 **Analysis Questions Answered, and Key Findings**

 Pillar 1: Exploratory Clinical Analysis
- Is there a difference in adverse event rates between male and female patients?
- Do older patients experience more Grade 3 and Grade 4 adverse events?
Key findings: Male patients recorded slightly more adverse events than female patients (92 vs 83) despite nearly equal enrollment numbers (61 males vs 59 females). Older patients experienced significantly more severe adverse events, patients aged 70 and above recorded 
23 Grade 3/4 events compared to just 7 in patients under 60, highlighting the need for closer monitoring of elderly patients in oncology trials.


Pillar 2: Patient Retention
- How many patients missed at least one visit?
- Which visit had the highest number of missed appointments?
- Which patients missed 2 or more visits?
Key findings: 45 out of 120 enrolled patients (37.5%) missed at least one scheduled visit. Missed visits peaked at Cycle 2 Day 1 with 
32 missed appointments. Further investigation confirmed that most of these were linked to active adverse events occurring around the
same time. 7 patients missed 2 or more visits, creating significant data gaps in the trial.

Pillar 3: Safety Monitoring
- How many adverse events occurred in each treatment arm?
- What are the top 5 most frequently reported adverse events?
- How many Grade 3 and Grade 4 events occurred across treatment arms?
- Which patients experienced a Serious Adverse Event?
Key findings: The top 5 most frequently reported adverse events were Alopecia, Peripheral Neuropathy, Fatigue, Rash and Neutropenia; all 
clinically consistent with chemotherapy treatment in NSCLC trials. While the Investigational arm recorded more Grade 3 events (25 vs 13), 
the Control arm recorded significantly more Grade 4 life-threatening events (12 vs 2). 8 patients experienced multiple Serious Adverse 
Events, with Patient 50 recording 4 SAEs before passing away during the trial.

Pillar 4: Site Performance
- How many patients did each site enroll vs their target?
- Which site had the highest number of missed visits?
Key findings: All 8 research sites met their target enrollment exactly. However Memorial Cancer Center recorded the highest number of missed visits at 13, partly attributed to having the largest patient enrollment at 20 patients. Atlantic Research Consortium performed best with only 3 missed visits.

Pillar 5: Data Quality
- Which patients had a dose deviation flagged?
- Which patients had their dose held and what arm are they in?
Key findings: 12 patients had dose deviations flagged during the trial, all due to 25% dose reductions following Grade 3 adverse events. All deviations were properly documented and justified, reflecting good clinical practice and regulatory compliance.


About Me
I am a Master of Public Health (MPH) student transitioning into the clinical trial space with a background in data analysis. This project was built to demonstrate my understanding of clinical trial operations and my ability to extract meaningful insights from complex trial data using SQL.





