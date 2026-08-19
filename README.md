# HR Employee Attrition Analytics

An end-to-end HR analytics project analyzing employee attrition drivers using **SQL, Power BI, and Excel** - built to simulate a real business analytics workflow, from raw data to a validated, decision-ready dashboard.

## Business Problem

A (simulated) ~865-employee company wants to understand **why employees are leaving** and **where retention risk is concentrated**, so HR and department leaders can prioritize interventions instead of reacting after the fact.

## Dataset

A synthetic, self-generated dataset built specifically for this project - 865 employees across 9 departments, normalized into 5 relational tables:

| Table | Description |
|---|---|
| `Employees` | Core employee demographic and job data |
| `Departments` | Department reference table |
| `SalaryHistory` | Salary changes over time (multiple rows per employee) |
| `Performance_Reviews` | Job satisfaction and work-life balance scores |
| `Attrition` | Leave status and exit date per employee |

## Tools & Techniques

- **SQL (MySQL):** Joins, subqueries, window functions (`TIMESTAMPDIFF`), data cleaning (deduplication, date standardization, orphan record removal)
- **Power BI:** DAX measures, calculated columns, cross-filtering slicers, dashboard design
- **Excel:** Pivot tables, `DATEDIF`, attrition cost modeling

## Repository Structure

```
├── data/                  # Source CSVs
├── sql/                   # SQL scripts (schema, cleaning, analysis, exports)
├── powerbi/                # Power BI dashboard (.pbix)
├── excel/                  # Excel pivot table + cost calculator
├── screenshots/            # Dashboard image(s)
└── README.md
```

## Approach

**1. Data Modeling & Cleaning (SQL)**
Designed a normalized 5-table schema with primary/foreign key constraints. Cleaned 865+ records: removed duplicates, standardized three different date formats, stripped currency formatting from salary fields, and removed orphaned foreign key references.

**2. Analysis (SQL)**
Queried attrition rate overall, by department, by tenure band, by salary band, and by job satisfaction / work-life balance score. Built an "at-risk" query flagging current employees under 12 months tenure with low satisfaction or work-life balance scores.

**3. Dashboard (Power BI)**
Connected Power BI directly to MySQL. Built KPI cards and four breakdown charts (department, tenure, salary, satisfaction) with cross-filtering department and tenure slicers. All DAX measures were validated against SQL query outputs to confirm accuracy.

**4. Cost Modeling (Excel)**
Built a pivot table cross-tabulating attrition rate by department and tenure band, and a replacement-cost calculator estimating the financial impact of attrition by department (adjustable cost-multiplier assumption, not hardcoded).

## Key Findings

- **Overall attrition rate: 20.81%** (180 of 865 employees)
- **Tenure is the strongest driver of attrition:** 44.02% in an employee's first year, dropping to 16.87% (1–3 yrs), 4.79% (3–5 yrs), and 0.00% at 5+ years -attrition is heavily front-loaded
- **Department attrition ranges from 16.85% (Marketing) to 24.44% (Customer Success)** - a moderate spread, with early tenure the more dominant pattern
- **Job satisfaction and work-life balance show a non-monotonic relationship with attrition** - lowest-scoring employees have the highest attrition, but the relationship doesn't decline in a straight line across the scale
- **32 current employees (~3.7% of the workforce)** flagged on an at-risk watchlist: under 12 months tenure with low satisfaction or work-life balance scores
- Estimated cost impact of attrition was modeled by department to translate the percentages above into a resourcing/budget conversation

## Data Validation

Every number in this project was cross-checked across all three tools — SQL query output, Power BI DAX measures, and Excel pivot tables were reconciled against each other at each stage, rather than trusting a single source. Two real bugs were caught and fixed this way (a DAX date-difference edge case, and a hidden zero-value bar chart issue caused by `DIVIDE()` returning blank).

## Notes & Caveats

- Dataset is synthetic, generated for portfolio purposes — figures represent patterns in the simulated data, not a real company
- A few department-level tenure breakdowns (e.g. Finance, People) are based on small sample sizes and are noted as directional rather than statistically robust
- ~14 employees have missing salary data and are excluded from salary-band analysis; ~107 employees have no performance review on record and are bucketed as "No Review" rather than imputed

## Author

Kartik
