USE TrekBikes;
GO
CREATE OR ALTER PROCEDURE dbo.DeleteCategory
    @Id SMALLINT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM dbo.Category WITH (UPDLOCK, HOLDLOCK) WHERE CategoryId = @Id)
        BEGIN
            COMMIT TRANSACTION;
            SELECT 0 AS Result;
            RETURN;
        END;
        IF EXISTS (SELECT 1 FROM dbo.SubCategory WHERE CategoryId = @Id)
        BEGIN
            COMMIT TRANSACTION;
            SELECT -1 AS Result;
            RETURN;
        END;
        DELETE FROM dbo.Category WHERE CategoryId = @Id;
        DECLARE @Affected INT = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT @Affected AS Result;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        IF ERROR_NUMBER() = 547
        BEGIN
            SELECT -1 AS Result;
            RETURN;
        END;
        THROW;
    END CATCH;
END;
GO
