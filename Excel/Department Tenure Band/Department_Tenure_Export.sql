-- Employee tenure export for Department x Tenure Band analysis
SELECT 
    e.EmployeeID,
    d.DepartmentName,
    e.HireDate,
    a.Attrition,
    a.ExitDate,
    TIMESTAMPDIFF(MONTH, e.HireDate, COALESCE(a.ExitDate, CURDATE())) AS TenureMonths
FROM Employees e
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN Attrition a ON e.EmployeeID = a.EmployeeID;