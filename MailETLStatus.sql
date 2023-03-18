/* ====================================================================================================================================

Purpose: This procedure gives the information of tables having rows more than expected threshold by sending an email

Parameter Info
@ProfileName = 'SQL_Email_Profile' Profile used to send mails
@recipients = '' The receipents of the mail
@CopyRecipients = '' The Cc members of the mail

Test Scripts
EXEC [dbo].[MailETLStatus] 'SQL_Email_Profile', '', ''
=======================================================================================================================================*/

CREATE PROCEDURE [dbo].[MailETLStatus] 
	 @ProfileName NVARCHAR(255)
	,@recipients NVARCHAR(550)
	,@CopyRecipients NVARCHAR(600)
AS
BEGIN
	DECLARE @Body VARCHAR(MAX)
		,@ServerName NVARCHAR(255)
		,@DWHName NVARCHAR(255)
		,@rows VARCHAR(MAX) = '';

	SET @ServerName = @@ServerName
	SET @DWHName = DB_NAME()

	DECLARE @Subject NVARCHAR(500) = 'Status of Tables Post ETL in [' + @DWHName + '] Environment';

	SET @Body = N'<H4 style="color:#FFFFF; font-family:sans-serif;font-weight:bold">Environment Details:</H5>' + N'<H5 style="color:#000000	; font-family:sans-serif"; font-weight: bold;>The Server Name is: ' + @ServerName + '</H5>' + N'<H5 style="color:#000000	; font-family:sans-serif; font-weight: bold;">The Datawarehouse Name is: ' + @DWHName + '</H5>' + N'<table border="2"; style="font-family:Arial,Verdana; text-align:left; font-size:9pt; color:#000033">' + 
		N'<tr style="text-align:left;">
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold; width:5%;">Table No.</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:20%;">Table Name</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:13%;">Current Row Count</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:10%;">Prev Row Count</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:10%;">Modified Date</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:10%;">Prev Modified Date</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:10%;">Threshold (%)</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:10%;">Current Diff</th>
<th style="text-align:left;background-color:#000080;color:#FFF;font-weight:bold;width:25%;">More Than Threshold</th>'

	SELECT @rows = @rows + CASE 
			WHEN MoreThanThreshold = 1
				THEN '<tr><th style="background-color:#ff0000;font-weight: normal;">' + CAST(tableNumberID AS NVARCHAR(255)) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + tableName + '</th><th style="background-color:#ff0000;font-weight: normal;">' + CAST(CurrRowCount AS NVARCHAR(255)) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + CAST(PrevRowCount AS NVARCHAR(255)) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + CAST(ModifiedDate AS NVARCHAR(255)) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + CAST(PrevModifiedDate AS NVARCHAR(255)) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + ISNULL(CAST(ThresholdPercentage AS NVARCHAR(255)), 0) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + CAST(CurrentDiff AS NVARCHAR(255)) + '</th><th style="background-color:#ff0000;font-weight: normal;">' + CAST(MoreThanThreshold AS NVARCHAR(255)) + '</th></tr>'
			ELSE '<tr><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(tableNumberID AS NVARCHAR(255)) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + tableName + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(CurrRowCount AS NVARCHAR(255)) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(PrevRowCount AS NVARCHAR(255)) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(ModifiedDate AS NVARCHAR(255)) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(PrevModifiedDate AS NVARCHAR(255)) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + ISNULL(CAST(ThresholdPercentage AS NVARCHAR(255)), 0) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(CurrentDiff AS NVARCHAR(255)) + '</th><th style="background-color:#90EE90	;font-weight: normal;">' + CAST(MoreThanThreshold AS NVARCHAR(255))
			END
	FROM [dbo].[TableRowsCount] WITH (NOLOCK)

	SELECT @Body = @Body + @rows + '</table></body></html>'

	IF (
			EXISTS (
				SELECT  1
				FROM [dbo].[TableRowsCount] WITH (NOLOCK)
				WHERE MoreThanThreshold = 1
				)
			)
	BEGIN
		EXEC msdb.dbo.Sp_send_dbmail @profile_name = 'SQL_Email_Profile'
			,@body = @Body
			,@body_format = 'html'
			,@recipients = 'XXXXXXXX@XXXXX.com'
			,@copy_recipients = 'XXXXXXX@XXXX.com'
			,@subject = @Subject
			,@Importance = 'High'
	END

	EXEC msdb.dbo.Sp_send_dbmail 
		 @profile_name = @ProfileName
		,@body = @Body
		,@body_format = 'html'
		,@recipients = @recipients
		,@copy_recipients = @CopyRecipients
		,@subject = @Subject
		,@Importance = 'Normal'
END