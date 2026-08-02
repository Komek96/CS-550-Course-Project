CREATE TABLE Station (
    StationId INT AUTO_INCREMENT PRIMARY KEY,
    FIPS INT,
    Latitude DOUBLE,
    Longitude DOUBLE
);

CREATE TABLE Event (
    EventId INT AUTO_INCREMENT PRIMARY KEY,
    StationId INT NOT NULL,
    Cruise VARCHAR(255),
    Program VARCHAR(255),
    Project VARCHAR(255),
    Agency VARCHAR(255),
    Source VARCHAR(255),
    TierLevel VARCHAR(50),
    FOREIGN KEY (StationId) REFERENCES Station(StationId)
);

CREATE TABLE Sample (
    SampleId INT AUTO_INCREMENT PRIMARY KEY,
    StationId INT NOT NULL,
    SampleDate DATE,
    SampleTime TIME,
    TotalDepth VARCHAR(50),
    UpperPycnocline VARCHAR(50),
    LowerPycnocline VARCHAR(50),
    Depth INT,
    Layer VARCHAR(50),
    SampleType VARCHAR(100),
    SampleReplicateType VARCHAR(100),
    FOREIGN KEY (StationId) REFERENCES Station(StationId)
);

CREATE TABLE Parameter (
    ParameterId INT AUTO_INCREMENT PRIMARY KEY,
    Parameter VARCHAR(255) NOT NULL
);

CREATE TABLE Method (
    MethodId INT AUTO_INCREMENT PRIMARY KEY,
    Method VARCHAR(255) NOT NULL
);

CREATE TABLE Lab (
    LabId INT AUTO_INCREMENT PRIMARY KEY,
    Lab VARCHAR(255) NOT NULL
);


CREATE TABLE Measure (
    MeasureId INT AUTO_INCREMENT PRIMARY KEY,
    SampleId INT NOT NULL,
    ParameterId INT NOT NULL,
    MethodId INT NOT NULL,
    LabId INT NOT NULL,
    Qualifier VARCHAR(255),
    MeasureValue DOUBLE,
    Unit VARCHAR(50),
    Problem TEXT,
    PrecisionPC VARCHAR(50),
    BiasPC VARCHAR(50),
    Details TEXT,
    FOREIGN KEY (SampleId) REFERENCES Sample(SampleId),
    FOREIGN KEY (ParameterId) REFERENCES Parameter(ParameterId),
    FOREIGN KEY (MethodId) REFERENCES Method(MethodId),
    FOREIGN KEY (LabId) REFERENCES Lab(LabId)
);

INSERT INTO Station (StationId, FIPS, Latitude, Longitude)
SELECT DISTINCT
    Station AS StationId,
    FIPS,
    Latitude,
    Longitude
FROM 
    raw_water_quality
WHERE 
    Station IS NOT NULL;

INSERT INTO Event (StationId, Cruise, Program, Project, Agency, Source, TierLevel)
SELECT DISTINCT
    Station AS StationId,
    Cruise,
    Program,
    Project,
    Agency,
    Source,
    TierLevel
FROM 
    raw_water_quality
WHERE 
    Station IS NOT NULL;

INSERT INTO Sample (
    StationId, SampleDate, SampleTime, TotalDepth, 
    UpperPycnocline, LowerPycnocline, Depth, Layer, SampleType, SampleReplicateType
)
SELECT DISTINCT
    Station AS StationId,
    STR_TO_DATE(SampleDate, '%m/%d/%Y') AS SampleDate,
    SampleTime,
    TotalDepth,
    UpperPycnocline,
    LowerPycnocline,
    Depth,
    Layer,
    SampleType,
    SampleReplicateType
FROM 
    raw_water_quality
WHERE 
    Station IS NOT NULL 
    AND SampleDate IS NOT NULL;

INSERT INTO Parameter (Parameter)
SELECT DISTINCT
    Parameter
FROM 
    raw_water_quality
WHERE 
    Parameter IS NOT NULL;

INSERT INTO Method (Method)
SELECT DISTINCT
    Method
FROM 
    raw_water_quality
WHERE 
    Method IS NOT NULL;
    
    INSERT INTO Lab (Lab)
SELECT DISTINCT
    Lab
FROM 
    raw_water_quality
WHERE 
    Lab IS NOT NULL;


INSERT INTO Measure (
    SampleId, ParameterId, MethodId, LabId, Qualifier, 
    MeasureValue, Unit, Problem, PrecisionPC, BiasPC, Details
)
SELECT DISTINCT
    (SELECT SampleId 
     FROM Sample 
     WHERE StationId = raw_water_quality.Station 
       AND SampleDate = STR_TO_DATE(raw_water_quality.SampleDate, '%m/%d/%Y') 
     LIMIT 1) AS SampleId,
    (SELECT ParameterId 
     FROM Parameter 
     WHERE Parameter = raw_water_quality.Parameter 
     LIMIT 1) AS ParameterId,
    (SELECT MethodId 
     FROM Method 
     WHERE Method = raw_water_quality.Method 
     LIMIT 1) AS MethodId,
    (SELECT LabId 
     FROM Lab 
     WHERE Lab = raw_water_quality.Lab 
     LIMIT 1) AS LabId,
    Qualifier,
    MeasureValue,
    Unit,
    Problem,
    PrecisionPC,
    BiasPC,
    Details
FROM 
    raw_water_quality
WHERE 
    Parameter IS NOT NULL 
    AND MeasureValue IS NOT NULL
    AND SampleDate IS NOT NULL;
