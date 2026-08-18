-- Latest salary + attrition cost export

SELECT 
    e.EmployeeID,
    d.DepartmentName,
    a.Attrition,
    sh.MonthlyIncome,
    sh.EffectiveDate,
    sh.MonthlyIncome * 12 AS AnnualSalary,
    CASE 
        WHEN a.Attrition = 'Yes' THEN (sh.MonthlyIncome * 12) * 1.5 
        ELSE 0 
    END AS ReplacementCost,
    1.5 AS ReplacementCostMultiplier
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Attrition a ON e.EmployeeID = a.EmployeeID
JOIN SalaryHistory sh ON e.EmployeeID = sh.EmployeeID
    AND sh.EffectiveDate = (
        SELECT MAX(sh2.EffectiveDate) 
        FROM SalaryHistory sh2 
        WHERE sh2.EmployeeID = sh.EmployeeID
    );