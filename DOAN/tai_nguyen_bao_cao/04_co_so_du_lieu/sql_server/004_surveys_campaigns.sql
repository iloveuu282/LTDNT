USE BusinessSurvey;
GO
IF OBJECT_ID('Surveys','U') IS NULL
BEGIN
    CREATE TABLE Surveys (
        SurveyId INT IDENTITY PRIMARY KEY,
        CategoryId INT NOT NULL REFERENCES Categories(CategoryId),
        Title NVARCHAR(150) NOT NULL,
        Description NVARCHAR(2000) NOT NULL,
        ImagePath VARCHAR(200) NOT NULL,
        QuestionsJson NVARCHAR(MAX) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_Surveys_Category ON Surveys(CategoryId, SurveyId DESC);
    CREATE TABLE PlanItems (
        MemberId INT NOT NULL REFERENCES Members(MemberId),
        SurveyId INT NOT NULL REFERENCES Surveys(SurveyId),
        TargetCount INT NOT NULL CHECK(TargetCount BETWEEN 1 AND 100000),
        PRIMARY KEY(MemberId, SurveyId)
    );
    CREATE TABLE Campaigns (
        CampaignId INT IDENTITY PRIMARY KEY,
        MemberId INT NOT NULL REFERENCES Members(MemberId),
        Title NVARCHAR(150) NOT NULL,
        Status VARCHAR(20) NOT NULL DEFAULT 'Pending'
            CHECK(Status IN ('Pending','Active','Closed','Cancelled')),
        RequestId UNIQUEIDENTIFIER NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        UNIQUE(MemberId, RequestId)
    );
    CREATE TABLE CampaignItems (
        ItemId INT IDENTITY PRIMARY KEY,
        CampaignId INT NOT NULL REFERENCES Campaigns(CampaignId),
        SurveyId INT NOT NULL REFERENCES Surveys(SurveyId),
        TargetCount INT NOT NULL CHECK(TargetCount BETWEEN 1 AND 100000),
        UNIQUE(CampaignId, SurveyId)
    );
    CREATE TABLE Responses (
        ResponseId INT IDENTITY PRIMARY KEY,
        ItemId INT NOT NULL REFERENCES CampaignItems(ItemId),
        MemberId INT NOT NULL REFERENCES Members(MemberId),
        SubmissionId UNIQUEIDENTIFIER NOT NULL UNIQUE,
        AnswersJson NVARCHAR(MAX) NOT NULL,
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        UNIQUE(ItemId, MemberId)
    );
END;
GO
