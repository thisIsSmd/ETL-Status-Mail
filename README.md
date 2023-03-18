# ETL-Status-Mail


Purpose: This procedure gives the information of tables having rows more than expected threshold by sending an email

Parameter Info

@ProfileName = 'SQL_Email_Profile' Profile used to send mails

@recipients = '' The receipents of the mail

@CopyRecipients = '' The Cc members of the mail

Test Scripts

EXEC [dbo].[MailETLStatus] 'SQL_Email_Profile', '', ''
