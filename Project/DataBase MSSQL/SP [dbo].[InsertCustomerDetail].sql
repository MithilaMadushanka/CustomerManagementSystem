USE [Customer]
GO
/****** Object:  StoredProcedure [dbo].[InsertCustomerDetail]    Script Date: 3/9/2024 1:26:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mithila Madushanka

-- =============================================
ALTER PROCEDURE [dbo].[InsertCustomerDetail]
(
	@JsonData		VARCHAR(MAX), 
	@operation		CHAR(1)
)
AS
BEGIN
	SET NOCOUNT ON;	

	DECLARE @sErrorProcedure	VARCHAR(200),
			@sLog				VARCHAR(500),
			@sErrorMessage		VARCHAR(500),
			@HaveValidation		BIT,
			@datetoday			DATE,
			@DBName				VARCHAR(100) =DB_NAME(),

			@HeaderID			INT,
			@IsValidation		BIT,
			@Validation			VARCHAR(150),
			@ReceiptNo			VARCHAR(50),
			@orderID			INT

	BEGIN TRY
		
				IF @operation='I'
					BEGIN
						IF OBJECT_ID('tempdb..#Insert') IS NOT NULL DROP TABLE #Insert
						CREATE TABLE #Insert (
							ID					INT IDENTITY,
							[Name]				VARCHAR(256),
							[PhoneNumber]		VARCHAR(12),
							[Email]				VARCHAR(50),
							[Address]			VARCHAR(MAX),
							[CreateDate]		DATETIME,
							[IsActive]			BIT
							)

						INSERT INTO #Insert ([Name],[PhoneNumber],[Email],[Address],[CreateDate],[IsActive])
						SELECT [Name],[PhoneNumber],[Email],[Address],GETDATE(),1
						FROM OPENJSON(@JsonData)  
						WITH 
						(
							[Name]			VARCHAR(256),
							[PhoneNumber]	VARCHAR(12),
							[Email]			VARCHAR(100),
							[Address]		VARCHAR(MAX)
						)

						IF EXISTS (SELECT 1 FROM  [dbo].[CustomerDetail] C 
						WHERE C.[Name]  IN (SELECT T.[Name] from #Insert T) AND C.PhoneNumber IN (SELECT T.[PhoneNumber] from #Insert T) )
						BEGIN
							SET @HaveValidation = 1
							RAISERROR ('The Customer already exists!',16,1)
							RETURN 0;
						END

						SET @IsValidation=0

						INSERT INTO [dbo].[CustomerDetail] ([Name],[PhoneNumber],[Email],[Address],[CreateDate],[IsActive])
						SELECT [Name],[PhoneNumber],[Email],[Address],[CreateDate],[IsActive]
						FROM #Insert
					END

					ELSE IF (@operation = 'U')
					BEGIN
						IF OBJECT_ID('tempdb..#Update') IS NOT NULL DROP TABLE #Update
							CREATE TABLE #Update (
								[ID]				INT,
								[Name]				VARCHAR(256),
								[PhoneNumber]		VARCHAR(12),
								[Email]				VARCHAR(50),
								[Address]			VARCHAR(MAX),
								[CreateDate]		DATETIME,
								[IsActive]			BIT	
							)
							INSERT INTO #Update (ID,[Name],[PhoneNumber],[Email],[Address],[CreateDate],[IsActive])
							SELECT ID,[Name],[PhoneNumber],[Email],[Address],[CreateDate],[IsActive]
							FROM OPENJSON(@JsonData)  
							WITH 
							(
								Id					INT ,
								[Name]				VARCHAR(256),
								[PhoneNumber]		VARCHAR(12),
								[Email]				VARCHAR(50),
								[Address]			VARCHAR(MAX),
								[CreateDate]		DATETIME,
								[IsActive]			BIT	
							)
						UPDATE C
						SET C.[Name] = U.Name ,
							C.[PhoneNumber] = U.PhoneNumber,
							C.[Email]	= U.Email,
							C.[Address] = U.Address							
						FROM  [dbo].[CustomerDetail] C
						INNER JOIN #Update U ON C.Id = U.Id
					END
			
	END TRY	
	BEGIN CATCH
		IF @@TRANCOUNT>0
			ROLLBACK TRANSACTION

		DECLARE @iErrorNumber INT

		SELECT	@sErrorProcedure=ERROR_PROCEDURE()
		SELECT	@sErrorMessage=ERROR_MESSAGE()
		SELECT	@iErrorNumber=ERROR_NUMBER()

		IF(@HaveValidation = 1)
		BEGIN
			EXEC sp_addmessage @msgnum = 50005, @severity = 1, @msgtext = @sErrorMessage,@replace = 'REPLACE';
			RAISERROR (50005,11,11)
		END
		ELSE
			RAISERROR (@sErrorMessage,16,1)

		RETURN 0
  
    END CATCH  
END
