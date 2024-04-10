# Lengthy Logs: Attack Analysis

This lab is a bit different as there is only one check that needs to be completed. The meeting minutes explain that there is a new tab in the menu for filling out a form. Filling out the form with the correct values results in a green check.

The "Incident Response" form fields are: 

- Which system was breached? If multiple, use multiple form submissions.
  - Database
- Which service was compromised on the breached system?
  - mysql
- What log file shows evidence of compromise? Please provide the full path.
  - C:\mysql_logs\mysql.log
- Which user account(s), if any, were tampered with? For multiple, use commas as the delimiter.
  - playerone, admin, gbates, takasaka

## Incident Response Form Correctly Submitted

Log into the `Database` machine and verify log location at `C:\mysql_logs\mysql.log`

The logs are pretty messy, so I used powershell to reformat them- `Select-String -Path C:\mysql_logs\mysql.log -Pattern "Query"`

I then looked at the database backup on `Backup`. It was located at `/DatabaseBackup/wordpress.sql`. I copied it over to `Security-Desk` using `scp` in order to better look at the logs- `scp /DatabaseBackup/wordpress.sql playerone@172.16.30.6:~/wordpress.sql`. It prompts you to enter in the password for `playerone`.

On `Security-Desk`, we can grep through the `wordpress.sql` file now located in our home directory to see the users in the database before the breach- `grep nickname ./wordpress.sql`. That gives us the final values to enter in the form and get a green check.
