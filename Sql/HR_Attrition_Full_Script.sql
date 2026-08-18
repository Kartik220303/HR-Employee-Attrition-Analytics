-- Create DataBase

Create Database if not exists hr_attrition;
Use hr_attrition;

-- Create Table and Importing Data

Create Table stg_departments (
DepartmentID int,
DepartmentName varchar(100),
Location varchar(100)
);

Create Table stg_employees (
EmployeeID int,
FirstName varchar(100),
LastName varchar(100),
Age int,
Gender varchar(20),
MaritalStatus varchar(20),
DepartmentID int,
JobRole varchar(100),
JobLevel int,
HireDate varchar(20),
Education varchar(20),
OverTime varchar(10),
RemoteWork varchar(10),
DistanceFromHome_km varchar(10),
NumCompaniesWorked int
);

Create Table stg_salary_history (
SalaryID int,
EmployeeID int,
EffectiveDate varchar(20),
MonthlyIncome varchar(20)
);

Create Table stg_performance_reviews (
ReviewID int,
EmployeeID int,
ReviewDate varchar(20),
PerformanceRating int,
JobSatisfaction varchar(10),
WorkLifeBalance varchar(10)
);

Create Table stg_attrition (
EmployeeID int,
Attrition varchar(5),
ExitDate varchar(20),
ExitReason varchar(100)
);

-- Verify Row Counts

Select 'stg_departments' as table_name, COUNT(*) AS row_count from stg_departments
union all
Select 'stg_employees', COUNT(*) from stg_employees
union all
Select 'stg_salary_history', COUNT(*) from stg_salary_history
union all
Select 'stg_performance_reviews', COUNT(*) from stg_performance_reviews
union all
Select 'stg_attrition', COUNT(*) from stg_attrition;

-- Check for Duplicates (stg_departments)

Select DepartmentID, count(*) as occurrences
from stg_departments
group by DepartmentID
having count(*) > 1;

-- Check for Blank/Null values (stg_departments)

Select *
from stg_departments
where DepartmentID is null
   or DepartmentName is null or DepartmentName = ''
   or Location is null or Location = '';

-- Check for Duplicates (stg_employees)

Select EmployeeID, count(*) as occurrences
from stg_employees
group by EmployeeID
having count(*) > 1;

-- Check for Blank/Null values (stg_employees)

Select 
    sum(case when MaritalStatus is null or MaritalStatus = '' then 1 else 0 end) as null_MaritalStatus,
    sum(case when Education is null or Education = '' then 1 else 0 end) as null_Education,
    sum(case when DistanceFromHome_km is null or DistanceFromHome_km = '' then 1 else 0 end) as null_Distance
from stg_employees;

-- Check for Duplicates (stg_salary_history)

Select SalaryID, count(*) as occurrences
from stg_salary_history
group by SalaryID
having count(*) > 1;

-- Check for Blank/Null values (stg_salary_history)

Select 
    sum(case when SalaryID is null then 1 else 0 end) as null_SalaryID,
    sum(case when EmployeeID is null then 1 else 0 end) as null_EmployeeID,
    sum(case when EffectiveDate is null or EffectiveDate = '' then 1 else 0 end) as null_EffectiveDate,
    sum(case when MonthlyIncome is null or MonthlyIncome = '' then 1 else 0 end) as null_MonthlyIncome
from stg_salary_history;
   
-- Check for Duplicates (stg_performance_review)
  
Select ReviewID, count(*) as occurrences
from stg_performance_reviews
group by ReviewID
having count(*) > 1;

-- Check for Blank/Null values (stg_performance_review)

Select 
    sum(case when ReviewID is null then 1 else 0 end) as null_ReviewID,
    sum(case when EmployeeID is null then 1 else 0 end) as null_EmployeeID,
    sum(case when ReviewDate is null or ReviewDate = '' then 1 else 0 end) as null_ReviewDate,
    sum(case when PerformanceRating is null then 1 else 0 end) as null_PerformanceRating,
    sum(case when JobSatisfaction is null or JobSatisfaction = '' then 1 else 0 end) as null_JobSatisfaction,
    sum(case when WorkLifeBalance is null or WorkLifeBalance = '' then 1 else 0 end) as null_WorkLifeBalance
from stg_performance_reviews;

-- Check for Duplicates (stg_attrition)

Select EmployeeID, count(*) as occurrences
from stg_attrition
group by EmployeeID
having count(*) > 1;

-- Check for Blank/Null values (stg_attrition)

Select 
    sum(case when EmployeeID is null then 1 else 0 end) as null_EmployeeID,
    sum(case when Attrition is null or Attrition = '' then 1 else 0 end) as null_Attrition,
    sum(case when ExitDate is null or ExitDate = '' then 1 else 0 end) as null_ExitDate,
    sum(case when ExitReason is null or ExitReason = '' then 1 else 0 end) as null_ExitReason
from stg_attrition;
   
-- Consistency check: Attrition = 'Yes' should always have an ExitDate

Select *
from stg_attrition
where Attrition = 'Yes' and (ExitDate is null or ExitDate = '');

-- CLEANING — Remove duplicate rows (stg_performance_reviews)

Create Table stg_performance_reviews_clean AS
Select ReviewID, EmployeeID, ReviewDate, PerformanceRating, JobSatisfaction, WorkLifeBalance
from (Select *,
    row_number() over (partition by ReviewID order by ReviewID) as row_num
    from stg_performance_reviews) as numbered
where row_num = 1;

Drop Table stg_performance_reviews;
Rename Table stg_performance_reviews_clean to stg_performance_reviews;

Select count(*) from stg_performance_reviews;
Select ReviewID, count(*) from stg_performance_reviews group by ReviewID having count(*) > 1;

-- Verify Row and Duplicates

Select count(*) from stg_employees;
Select EmployeeID, count(*) from stg_employees group by EmployeeID having count(*) > 1;

-- CLEANING — Remove duplicate rows (stg_employees)

Create Table stg_employees_clean as
Select EmployeeID, FirstName, LastName, Age, Gender, MaritalStatus, DepartmentID, 
       JobRole, JobLevel, HireDate, Education, OverTime, RemoteWork, 
       DistanceFromHome_km, NumCompaniesWorked
from (Select *,
	 row_number() over(partition by EmployeeID order by EmployeeID) as row_num
     from stg_employees) as numbered
     where row_num = 1;

Drop Table stg_employees;
Rename Table stg_employees_clean to stg_employees;

-- Verify Row and Duplicates

Select count(*) from stg_employees;
Select EmployeeID, count(*) from stg_employees group by EmployeeID having count(*) > 1;

-- Find HireDate values that don't match the expected YYYY-MM-DD format

Select EmployeeID, HireDate
from stg_employees
where HireDate not regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

Select
    sum(case when HireDate regexp '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$' then 1 else 0 end) as format_month_name,
    sum(case when HireDate regexp '^[0-9]{2}/[0-9]{2}/[0-9]{4}$' then 1 else 0 end) as format_slash,
    sum(case when HireDate regexp '^[0-9]{2}-[0-9]{2}-[0-9]{4}$' then 1 else 0 end) as format_dash,
    count(*) as total_malformed
from stg_employees
where HireDate not regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Convert "Month DD, YYYY" format

Update stg_employees
Set HireDate = date_format(str_to_date(HireDate, '%M %d, %Y'), '%Y-%m-%d')
Where HireDate regexp '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$';

Select EmployeeID, HireDate
from stg_employees
where HireDate not regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Convert "MM/DD/YYYY"

Update stg_employees
Set HireDate = date_format(str_to_date(HireDate, '%m/%d/%Y'), '%Y-%m-%d')
Where HireDate regexp '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

-- Convert "DD-MM-YYYY" format e.g. "31-03-2023"

Update stg_employees
Set HireDate = DATE_FORMAT(STR_TO_DATE(HireDate, '%d-%m-%Y'), '%Y-%m-%d')
Where HireDate regexp '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';

Select EmployeeID, HireDate
from stg_employees
where HireDate not regexp '^[0-9]{4}-[0-9]{2}-[0-9]{2}$';

-- Find the MonthlyIncome with symbols or commas

Select distinct MonthlyIncome
from stg_salary_history
where MonthlyIncome regexp '[^0-9.]'
limit 30;

-- Confirm total count of dirty rows and check the pattern truly is only $ and , 

Select count(*) as dirty_count
from stg_salary_history
where MonthlyIncome regexp '[^0-9.]';

-- Strip currency formatting (stg_salary_history)

Update stg_salary_history
Set MonthlyIncome = replace(replace(MonthlyIncome, '$', ''), ',', '')
Where MonthlyIncome regexp '[^0-9.]';

Select COUNT(*) as still_dirty
from stg_salary_history
where MonthlyIncome regexp '[^0-9.]';

-- Orphan EmployeeIDs in stg_salary_history (referencing employees that don't exist)

Select distinct s.EmployeeID
from stg_salary_history s
left join stg_employees e on s.EmployeeID = e.EmployeeID
where e.EmployeeID is null;

-- Orphan EmployeeIDs in stg_performance_reviews (referencing employees that don't exist)

Select distinct p.EmployeeID
from stg_performance_reviews p
left join stg_employees e on p.EmployeeID = e.EmployeeID
where e.EmployeeID is null;

-- Remove orphan foreign keys (stg_salary_history)

Delete from stg_salary_history
where EmployeeID not in (
   Select EmployeeID from stg_employees
   );

-- Remove orphan foreign keys (stg_performance_reviews)

Delete from stg_performance_reviews
where EmployeeID not in  (
   Select EmployeeID from stg_employees
   );

-- Verfify Both counts

Select count(*) from stg_salary_history;
Select count(*) from stg_performance_reviews;

-- Production Schema - Departments

Create table Departments (
    DepartmentID int primary key,
    DepartmentName varchar(100) not null,
    Location varchar(100)
);

Insert into Departments
Select * from stg_departments;

-- Production Schema - Employees

Create Table Employees (
 EmployeeID int primary key,
 FirstName varchar(100) not null,
 LastName varchar(100) not null,
 Age int,
 Gender varchar(20),
 MaritalStatus varchar(20),
 DepartmentID int,
 JobRole varchar(100),
 JobLevel int,
 HireDate date,
 Education varchar(20),
 OverTime varchar(10),
 RemoteWork varchar(10),
 DistanceFromHome_km decimal(6,2),
 NumCompaniesWorked int,
 foreign key (DepartmentID) references Departments(DepartmentID)
);

Insert into Employees
Select
 EmployeeID, FirstName, LastName, Age, Gender, MaritalStatus, DepartmentID,
 JobRole, JobLevel,
 str_to_date(HireDate, '%Y-%m-%d'),
 Education, OverTime, RemoteWork,
 nullif(DistanceFromHome_km, ''),
 NumCompaniesWorked
from stg_employees;

-- Production Schema - SalaryHistory

Create Table SalaryHistory (
 SalaryID int primary key,
 EmployeeID int,
 EffectiveDate date,
 MonthlyIncome decimal(10,2),
 foreign key (EmployeeID) references Employees(EmployeeID)
);

Insert into SalaryHistory
Select
 SalaryID, EmployeeID,
 str_to_date(EffectiveDate, '%Y-%m-%d'),
 nullif(MonthlyIncome, '')
from stg_salary_history;

-- Production Schema - PerformanceReviews

Create Table Performance_Reviews (
 ReviewID int primary key,
 EmployeeID int,
 ReviewDate date,
 PerformanceRating int,
 JobSatisfaction decimal(3,1),
 WorkLifeBalance decimal(3,1),
 foreign key (EmployeeID) references Employees(EmployeeID)
);

Insert into Performance_Reviews
Select
 ReviewID, EmployeeID,
 STR_TO_DATE(ReviewDate, '%Y-%m-%d'),
 PerformanceRating,
 NULLIF(JobSatisfaction, ''),
 NULLIF(WorkLifeBalance, '')
from stg_performance_reviews;

-- Production Schema - Attrition

Create Table Attrition (
 EmployeeID int primary key,
 Attrition varchar(5),
 ExitDate date,
 ExitReason varchar(100),
 foreign key (EmployeeID) references Employees(EmployeeID)
);

Insert into Attrition
Select
 EmployeeID, Attrition,
 str_to_date(nullif(ExitDate, ''), '%Y-%m-%d'),
 nullif(ExitReason, '')
from stg_attrition;

-- Confirm foreign keys exist and point where expected
Select Table_Name, Column_Name, Constraint_Name, Referenced_Table_Name, Referenced_Column_Name
from information_schema.KEY_COLUMN_USAGE
where Table_Schema = 'hr_attrition'
  and Referenced_Table_Name is not null;
  
-- Analysis - Overall Attrition Rate

Select
 Attrition,
 count(*) as employee_count,
 round(count(*) * 100.0 / (Select count(*) from Attrition), 2) as percentage
from Attrition
group by Attrition;

-- Analysis - Attrition Rate by Department

Select 
 d.DepartmentName,
 count(*) as total_employees,
 sum(case when a.Attrition = 'Yes' then 1 else 0 end) as attrition_count,
 round(sum(case when a.Attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*), 2) as attrition_rate_pct
from Employees e
join Departments d on e.DepartmentID = d.DepartmentID
join Attrition a on e.EmployeeID = a.EmployeeID
group by d.DepartmentName
order by attrition_rate_pct desc;

-- Tenure Calculation - Employees + Attrition

Select
 e.EmployeeID,
 e.HireDate,
 a.Attrition,
 a.ExitDate,
 coalesce(a.ExitDate, curdate()) as EffectiveEndDate,
 timestampdiff(month, e.HireDate, coalesce(a.ExitDate, CURDATE())) as TenureMonths
from Employees e
Join Attrition a 
 on e.EmployeeID = a.EmployeeID
limit 10;

-- Tenure Validation - Full Dataset Sanity Checks

-- Aggregate sanity - row count, min/max/avg tenure
Select
    Min(timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate()))) as MinTenure,
    Max(timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate()))) as MaxTenure,
    Avg(timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate()))) as AvgTenure,
    count(*) as TotalRows
from Employees e
Join Attrition a on e.EmployeeID = a.EmployeeID;

-- Data integrity - ExitDate should never be before HireDate
Select e.EmployeeID, e.HireDate, a.ExitDate
from Employees e
Join Attrition a on e.EmployeeID = a.EmployeeID
Where a.ExitDate < e.HireDate;

-- Attrition flag and ExitDate should agree
Select Attrition,
 sum(case when ExitDate is null then 1 else 0 end) as NullExitDates,
 sum(case when ExitDate is not null then 1 else 0 end) as NonNullExitDates
from Attrition
Group by Attrition;

-- Tenure Banding - Employees + Attrition

Select
 Case
	when timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate())) < 12  then '<1 year'
	when timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate())) < 36  then '1-3 years'
	when timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate())) < 60  then '3-5 years'
	else '5+ years'
end as TenureBand,
count(*) as TotalEmployees,
sum(case when a.Attrition = 'Yes' then 1 else 0 end) as LeftCount,
round(sum(case when a.Attrition = 'Yes' then 1 ELSE 0 end) * 100.0 / count(*), 2) AS AttritionRatePct
from Employees e
Join Attrition a ON e.EmployeeID = a.EmployeeID
Group by TenureBand
Order by min(timestampdiff(month, e.HireDate, coalesce(a.ExitDate, curdate())));

-- Salary Distribution Check
Select
 Min(MonthlyIncome) as MinIncome,
 Max(MonthlyIncome) as MaxIncome,
 Round(avg(MonthlyIncome), 2) as AvgIncome,
 Round(stddev(MonthlyIncome), 2) as StdDevIncome,
 Sum(case when MonthlyIncome is null then 1 else 0 end) as NullIncomeCount
from SalaryHistory;

-- Salary history row count per employee
Select count(*) as TotalRows, count(distinct EmployeeID) as UniqueEmployees
from SalaryHistory;

-- Salary history structure
Describe salaryhistory;

-- Latest salary distribution check
Select
 Min(t.MonthlyIncome) as MinIncome,
 Max(t.MonthlyIncome) as MaxIncome,
 Round(avg(t.MonthlyIncome), 2) as AvgIncome,
 Round(stddev(t.MonthlyIncome), 2) as StdDevIncome,
 Sum(case when t.MonthlyIncome is null then 1 else 0 end) as NullIncomeCount
from (
 Select sh.EmployeeID, sh.EffectiveDate, sh.MonthlyIncome
 from SalaryHistory sh
 inner join (
	Select EmployeeID, max(EffectiveDate) as LatestDate
	from SalaryHistory
	group by EmployeeID
) latest
	on sh.EmployeeID = latest.EmployeeID
	and sh.EffectiveDate = latest.LatestDate
) t;

-- Salary brand attrition

Select
 case
    when t.MonthlyIncome is null then 'Unknown'
	when t.MonthlyIncome < 6450 then 'Low'
	when t.MonthlyIncome < 13960 then 'Mid'
	when t.MonthlyIncome < 17715 then 'High'
	else 'Very High'
end as SalaryBand,
Count(*) as TotalEmployees,
Sum(case when a.Attrition = 'Yes' then 1 else 0 end) as LeftCount,
Round(sum(case when a.Attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*), 2) as AttritionRatePct
from (
Select sh.EmployeeID, sh.MonthlyIncome
from SalaryHistory sh
Inner join (
	Select EmployeeID, max(EffectiveDate) as LatestDate
	from SalaryHistory
	group by EmployeeID
) latest
	on sh.EmployeeID = latest.EmployeeID
	and sh.EffectiveDate = latest.LatestDate
) t
Join Attrition a on t.EmployeeID = a.EmployeeID
group by SalaryBand
order by min(t.MonthlyIncome);

-- Satifaction / Work life balance distribution check
Select
 Min(JobSatisfaction) as MinSatisfaction,
 Max(JobSatisfaction) as MaxSatisfaction,
 Sum(case when JobSatisfaction is null then 1 else 0 end) as NullSatisfaction,
 Min(WorkLifeBalance) as MinWLB,
 Max(WorkLifeBalance) as MaxWLB,
 Sum(case when WorkLifeBalance is null then 1 else 0 end) as NullWLB,
 Count(*) as TotalRows,
 Count(distinct EmployeeID) as UniqueEmployees
from performance_reviews;

-- Null overlap check - JobSatisfaction vs Work life balance
Select
 Sum(case when JobSatisfaction is null and WorkLifeBalance is null then 1 else 0 end) as BothNull,
 Sum(case when JobSatisfaction is null and WorkLifeBalance is not null then 1 else 0 end) as OnlySatisfactionNull,
 Sum(case when JobSatisfaction is not null and WorkLifeBalance is null then 1 else 0 end) as OnlyWLBNull
from performance_reviews;

-- Satisfaction vs Attrition

Select
Case
	when pr.JobSatisfaction is null then 'No Review / Unknown'
	when pr.JobSatisfaction = 1 then '1 - Low'
	when pr.JobSatisfaction = 2 then '2 - Medium-Low'
	when pr.JobSatisfaction = 3 then '3 - Medium-High'
	when pr.JobSatisfaction = 4 then '4 - High'
end as SatisfactionBand,
Count(*) as TotalEmployees,
Sum(case when a.Attrition = 'Yes' then 1 else 0 end) as LeftCount,
Round(sum(case when a.Attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*), 2) as AttritionRatePct
from Employees e
Left join performance_reviews pr on e.EmployeeID = pr.EmployeeID
Join Attrition a on e.EmployeeID = a.EmployeeID
Group by SatisfactionBand
Order by min(pr.JobSatisfaction);

-- Work life balance vs Attrition

Select
Case
	when pr.WorkLifeBalance is null then'No Review / Unknown'
	when pr.WorkLifeBalance = 1 then '1 - Low'
	when pr.WorkLifeBalance = 2 then '2 - Medium-Low'
	when pr.WorkLifeBalance = 3 then '3 - Medium-High'
	when pr.WorkLifeBalance = 4 then '4 - High'
end as WLBBand,
Count(*) as TotalEmployees,
Sum(case when a.Attrition = 'Yes' then 1 else 0 end) as LeftCount,
Round(sum(case when a.Attrition = 'Yes' then 1 else 0 end) * 100.0 / count(*), 2) as AttritionRatePct
from Employees e
Left join performance_reviews pr on e.EmployeeID = pr.EmployeeID
Join Attrition a on e.EmployeeID = a.EmployeeID
Group by WLBBand
Order by min(pr.WorkLifeBalance);

-- At Risk employee list

Select
 e.EmployeeID,
 e.HireDate,
 Timestampdiff(month, e.HireDate, curdate()) as TenureMonths,
 pr.JobSatisfaction,
 pr.WorkLifeBalance
from Employees e
Join Attrition a on e.EmployeeID = a.EmployeeID
Left join performance_reviews pr on e.EmployeeID = pr.EmployeeID
Where a.Attrition = 'No'
  and timestampdiff(month, e.HireDate, curdate()) < 12
  and (pr.JobSatisfaction <= 2 or pr.WorkLifeBalance <= 2)
Order by TenureMonths, pr.JobSatisfaction;