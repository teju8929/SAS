proc import datafile="/home/u63706105/grc_qi_coding_exercise.csv" 
    out=patient_data
    dbms=csv
    replace;
run;

data patient_data;
    set patient_data;
    VisitDateFormatted = input(VisitDate, yymmdd10.);
    format VisitDateFormatted yymmdd10.;
run;

* Question 1;
proc sql;
    create table unique_patients as 
    select count(distinct PatID) as NumberOfPatients
    from patient_data
    where SiteName = 'Clinic 1' and VisitDate <= '30APR2030'd;
quit;

proc print data=unique_patients;
    title "1. Number of Patients Visited Clinic 1 on or before April 30, 2030";
run;

* Question 2;
proc sql;
	create table AgeAtVisit as 
	select avg(AgeAtVisit) as AverageAge
    from patient_data
    where A1C >= 9.0;
quit;

proc print data=AgeAtVisit;
    title "2. Average Patient Age Among All Visits with an A1C Value of Greater or Equal to 9.0";
run;

* Question 3;
proc sql;
    create table AgedHyper as
    select count(distinct PatID) as NumberPatients
    from (
        select PatID, count(*) as VisitCount
        from patient_data
        where AgeAtVisit <= 50 and SysBP > 140 and DiasBP > 90
        group by PatID
        having count(*) >= 2
    );
quit;

proc print data=AgedHyper;
    title "3. Patients Aged 50 or Younger with Hypertension on at Least Two Separate Visits";
run;

* Question 4;
proc sql;
	create table PHQ4 as
    select count(distinct PatID) as NumberOfPatients
    from patient_data
    where SiteName = 'Clinic 2' and DepScreen = 'Y' and PHQ <= 4 and PHQ is not missing;
quit;

proc print data=PHQ4;
    title "4. Patients at Clinic 2 with Depression Screening and a PHQ Score of 4 or Lower";
run;

* Question 5;
proc sql;
    create table male_hypertension_followup as
	SELECT SiteName,
       SUM(CASE WHEN HypFollowUpSch = 'Y' THEN 1 ELSE 0 END) AS FollowUpScheduled,
       COUNT(*) AS TotalVisits,
       ROUND((SUM(CASE WHEN HypFollowUpSch = 'Y' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) AS ProportionPercentage
	FROM patient_data
	WHERE SiteName IN ('Clinic 1', 'Clinic 3')
	      AND Sex = 'M'
	      AND (SysBP > 140 OR DiasBP > 90)
	GROUP BY SiteName;
quit;

proc print data=male_hypertension_followup;
    title "5. Proportion of Hypertension Follow-Up Visits Scheduled for Male Patients at Clinic 1 and Clinic 3";
run;
