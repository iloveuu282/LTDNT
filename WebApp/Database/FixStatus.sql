IF OBJECT_ID('dbo.Status', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Status (
        StatusId SMALLINT NOT NULL PRIMARY KEY,
        StatusName NVARCHAR(64) NOT NULL
    );
END;

INSERT INTO dbo.Status (StatusId, StatusName)
SELECT seed.StatusId, seed.StatusName
FROM (VALUES
    (0, N'Cancel'),
    (1, N'watting'),
    (2, N'Approved'),
    (3, N'Shipping'),
    (4, N'Finished')
) seed(StatusId, StatusName)
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Status existing WHERE existing.StatusId = seed.StatusId
);
