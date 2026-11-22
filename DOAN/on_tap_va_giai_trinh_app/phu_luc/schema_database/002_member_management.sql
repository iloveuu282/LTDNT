USE BusinessSurvey;
GO
IF COL_LENGTH('Members', 'IsActive') IS NULL
    ALTER TABLE Members ADD IsActive BIT NOT NULL CONSTRAINT DF_Members_IsActive DEFAULT 1;
IF COL_LENGTH('Members', 'TokenVersion') IS NULL
    ALTER TABLE Members ADD TokenVersion INT NOT NULL CONSTRAINT DF_Members_TokenVersion DEFAULT 0;
GO
