WITH MonthlyMaxCHLA AS (
    SELECT 
        Sample.StationId,
        MONTH(Sample.SampleDate) AS Month,
        MAX(Measure.MeasureValue) AS MaxCHLA
    FROM 
        Measure
    JOIN 
        Parameter ON Measure.ParameterId = Parameter.ParameterId
    JOIN 
        Sample ON Measure.SampleId = Sample.SampleId
    WHERE 
        Parameter.Parameter = 'CHLA' -- Filter for CHLA measurements
    GROUP BY 
        Sample.StationId, MONTH(Sample.SampleDate)
),
StationsBelowThreshold AS (
    SELECT 
        StationId
    FROM 
        MonthlyMaxCHLA
    WHERE 
        MaxCHLA <= 18.0
    GROUP BY 
        StationId
    HAVING COUNT(DISTINCT Month) = 12 -- Ensure all months are below the threshold
)
SELECT 
    mm.StationId,
    mm.Month,
    mm.MaxCHLA
FROM 
    MonthlyMaxCHLA mm
JOIN 
    StationsBelowThreshold sbt ON mm.StationId = sbt.StationId
WHERE 
    mm.MaxCHLA <= 18.0
ORDER BY 
    mm.StationId, mm.Month;
