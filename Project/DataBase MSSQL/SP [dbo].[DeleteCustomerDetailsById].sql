USE [Customer]
GO
/****** Object:  StoredProcedure [dbo].[DeleteCustomerDetailsById]    Script Date: 3/9/2024 1:25:36 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Mithila Madushanka

-- =============================================
ALTER PROCEDURE [dbo].[DeleteCustomerDetailsById]
(	
	@CustomerID		INT
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
		
			--Soft Delete used
			UPDATE  [dbo].[CustomerDetail] SET IsActive = 0 WHERE  Id = @CustomerID
			--DELETE C FROM [dbo].[CustomerDetail] C WHERE C.Id = @CustomerID
		
			IF @@TRANCOUNT>0
				COMMIT TRANSACTION
				RETURN 1
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
