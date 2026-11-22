IF DB_ID(N'BusinessSurvey') IS NULL
    CREATE DATABASE BusinessSurvey;
GO
USE BusinessSurvey;
GO
IF OBJECT_ID(N'Roles', N'U') IS NULL
BEGIN
    CREATE TABLE Roles (
        RoleId INT IDENTITY PRIMARY KEY,
        RoleName VARCHAR(20) NOT NULL UNIQUE
    );
    INSERT INTO Roles (RoleName) VALUES ('Admin'), ('Member');
END;
IF OBJECT_ID(N'Members', N'U') IS NULL
BEGIN
    CREATE TABLE Members (
        MemberId INT IDENTITY PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email VARCHAR(254) NOT NULL UNIQUE,
        PasswordHash VARCHAR(100) NOT NULL,
        RoleId INT NOT NULL REFERENCES Roles(RoleId),
        CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END;
IF OBJECT_ID(N'Categories', N'U') IS NULL
BEGIN
    CREATE TABLE Categories (
        CategoryId INT IDENTITY PRIMARY KEY,
        CategoryName NVARCHAR(100) NOT NULL UNIQUE,
        Description NVARCHAR(500) NULL
    );
    INSERT INTO Categories (CategoryName, Description) VALUES
    (N'Khách hàng', N'Khảo sát mức độ hài lòng của khách hàng'),
    (N'Nhân sự', N'Khảo sát ý kiến nhân viên'),
    (N'Thị trường', N'Thu thập nhu cầu và xu hướng thị trường');
END;
