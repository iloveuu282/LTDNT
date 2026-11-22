USE BusinessSurvey;
GO
IF COL_LENGTH('Categories', 'ImagePath') IS NULL
    ALTER TABLE Categories ADD ImagePath NVARCHAR(300) NULL;
GO
