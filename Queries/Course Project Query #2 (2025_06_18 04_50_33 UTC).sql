WITH MaxCHLA AS (
    SELECT 
        Sample.StationId,
        MAX(Measure.MeasureValue) AS MaxCHLA
    FROM 
        Measure
    JOIN 
        Parameter ON Measure.ParameterId = Parameter.ParameterId
    JOIN 
        Sample ON Measure.SampleId = Sample.SampleId
    WHERE 
        Parameter.Parameter = 'CHLA'
    GROUP BY 
        Sample.StationId
),
MinCHLA AS (
    SELECT 
        Sample.StationId,
        MIN(Measure.MeasureValue) AS MinCHLA
    FROM 
        Measure
    JOIN 
        Parameter ON Measure.ParameterId = Parameter.ParameterId
    JOIN 
        Sample ON Measure.SampleId = Sample.SampleId
    WHERE 
        Parameter.Parameter = 'CHLA'
    GROUP BY 
        Sample.StationId
)
SELECT 
    mx.StationId,
    mx.MaxCHLA,
    (SELECT Sample.SampleDate 
     FROM Measure
     JOIN Sample ON Measure.SampleId = Sample.SampleId
     JOIN Parameter ON Measure.ParameterId = Parameter.ParameterId
     WHERE Parameter.Parameter = 'CHLA' 
       AND Measure.MeasureValue = mx.MaxCHLA 
       AND Sample.StationId = mx.StationId
     LIMIT 1) AS MaxCHLADate,
    (SELECT Sample.SampleTime 
     FROM Measure
     JOIN Sample ON Measure.SampleId = Sample.SampleId
     JOIN Parameter ON Measure.ParameterId = Parameter.ParameterId
     WHERE Parameter.Parameter = 'CHLA' 
       AND Measure.MeasureValue = mx.MaxCHLA 
       AND Sample.StationId = mx.StationId
     LIMIT 1) AS MaxCHLATime,
    mn.MinCHLA,
    (SELECT Sample.SampleDate 
     FROM Measure
     JOIN Sample ON Measure.SampleId = Sample.SampleId
     JOIN Parameter ON Measure.ParameterId = Parameter.ParameterId
     WHERE Parameter.Parameter = 'CHLA' 
       AND Measure.MeasureValue = mn.MinCHLA 
       AND Sample.StationId = mn.StationId
     LIMIT 1) AS MinCHLADate,
    (SELECT Sample.SampleTime 
     FROM Measure
     JOIN Sample ON Measure.SampleId = Sample.SampleId
     JOIN Parameter ON Measure.ParameterId = Parameter.ParameterId
     WHERE Parameter.Parameter = 'CHLA' 
       AND Measure.MeasureValue = mn.MinCHLA 
       AND Sample.StationId = mn.StationId
     LIMIT 1) AS MinCHLATime
FROM 
    MaxCHLA mx
JOIN 
    MinCHLA mn ON mx.StationId = mn.StationId
ORDER BY 
    mx.StationId;
