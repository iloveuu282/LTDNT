USE TrekBikes;
GO
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    DECLARE @Id SMALLINT;
    ;WITH Candidate AS (
        SELECT CAST(1 AS INT) AS Id
        UNION ALL SELECT Id + 1 FROM Candidate WHERE Id < 32767
    )
    SELECT TOP (1) @Id = Id FROM Candidate
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Category c WHERE c.CategoryId = Candidate.Id)
    ORDER BY Id OPTION (MAXRECURSION 0);
    IF @Id IS NULL THROW 50001, N'Không còn ID để kiểm tra.', 1;

    INSERT INTO dbo.Category (CategoryId, CategoryName, Title, Description, Icon)
    VALUES (@Id, N'Test', N'Test title', N'Test description', 'test.png');
    DECLARE @Result TABLE (Result INT);
    INSERT INTO @Result EXEC dbo.DeleteCategory @Id = @Id;
    IF (SELECT Result FROM @Result) <> 1 THROW 50002, N'Xóa danh mục trống phải trả 1.', 1;
    DELETE FROM @Result;
    INSERT INTO @Result EXEC dbo.DeleteCategory @Id = @Id;
    IF (SELECT Result FROM @Result) <> 0 THROW 50003, N'ID không tồn tại phải trả 0.', 1;

    INSERT INTO dbo.Category (CategoryId, CategoryName, Title, Description, Icon)
    VALUES (@Id, N'Test', N'Test title', N'Test description', 'test.png');
    INSERT INTO dbo.SubCategory (CategoryId, SubCategoryName, Title, Description, ImageUrl)
    VALUES (@Id, N'Test child', N'Test title', N'Test description', 'test.png');
    DELETE FROM @Result;
    INSERT INTO @Result EXEC dbo.DeleteCategory @Id = @Id;
    IF (SELECT Result FROM @Result) <> -1 THROW 50004, N'Danh mục có danh mục con phải trả -1.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Category WHERE CategoryId = @Id)
        THROW 50005, N'Danh mục có con đã bị xóa.', 1;
    ROLLBACK TRANSACTION;
    PRINT N'PASS: DeleteCategory trả đúng 1 / 0 / -1; dữ liệu kiểm tra đã rollback.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO
