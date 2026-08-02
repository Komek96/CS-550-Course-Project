WITH MonthlyAverage AS (
    SELECT 
        MONTH(Sample.SampleDate) AS Month,
        AVG(Measure.MeasureValue) AS AvgCHLA
    FROM 
        Measure
    JOIN 
        Parameter ON Measure.ParameterId = Parameter.ParameterId
    JOIN 
        Sample ON Measure.SampleId = Sample.SampleId
    WHERE 
        Parameter.Parameter = 'CHLA'
    GROUP BY 
        MONTH(Sample.SampleDate)
),
OverallAverage AS (
    SELECT 
        AVG(Measure.MeasureValue) AS OverallAvgCHLA
    FROM 
        Measure
    JOIN 
        Parameter ON Measure.ParameterId = Parameter.ParameterId
    WHERE 
        Parameter.Parameter = 'CHLA'
)
SELECT 
    m.Month,
    m.AvgCHLA,
    o.OverallAvgCHLA,
    CASE 
        WHEN m.AvgCHLA > o.OverallAvgCHLA THEN 'Above Average'
        WHEN m.AvgCHLA < o.OverallAvgCHLA THEN 'Below Average'
        ELSE 'Equal to Average'
    END AS Comparison
FROM 
    MonthlyAverage m
CROSS JOIN 
    OverallAverage o
ORDER BY 
    m.Month;
