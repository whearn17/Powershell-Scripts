# Import necessary namespaces
Add-Type -TypeDefinition @"
using System.Net.Mail;
using System.Net;
using System.Collections.Specialized;
"@ -Language CSharp

# Setup SMTP Client
$smtpServer = 'smtp.yourmailserver.com' # Replace with your SMTP server
$smtpFrom = 'your-email@example.com'    # Replace with your email address
$smtpTo = 'recipient@example.com'       # Replace with the recipient's email address
$smtp = New-Object Net.Mail.SmtpClient($smtpServer)

# You may need to provide NetworkCredential if your SMTP server requires authentication
$smtp.Credentials = New-Object Net.NetworkCredential('username', 'password') # Replace with your username and password

# Create MailMessage object
$mailmessage = New-Object Net.Mail.MailMessage $smtpFrom, $smtpTo
$mailmessage.Subject = 'Subject of your mail'
$mailmessage.Body = 'Body of your mail'

# Add or change headers
$mailmessage.Headers.Add('X-Custom-Header', 'CustomHeaderValue')

# Send the email
$smtp.Send($mailmessage)

# Dispose of objects
$mailmessage.Dispose()
$smtp.Dispose()
