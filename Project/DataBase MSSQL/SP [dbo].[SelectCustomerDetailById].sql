USE [Customer]
GO
/****** Object:  StoredProcedure [dbo].[SelectCustomerDetailById]    Script Date: 3/9/2024 1:27:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mithila Madushanka

-- =============================================
ALTER PROCEDURE [dbo].[SelectCustomerDetailById]
(
	@CustomerId		INT
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
		
			SELECT 
					Id,
					Name,
					PhoneNumber,
					Email,
					Address,
					CreateDate,
					IsActive FROM [dbo].[CustomerDetail] WHERE Id = @CustomerId AND IsActive = 1			
		
	END TRY
	BEGIN CATCH

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
