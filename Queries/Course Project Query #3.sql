SELECT 
    SampleReplicateType,
    COUNT(*) AS TotalSamples
FROM 
    Sample
GROUP BY 
    SampleReplicateType
ORDER BY 
    TotalSamples DESC;
