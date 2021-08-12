# WinEventLogReport

# Preqrequisites:
This script requires thatSysmon from the MS Sysinternal Suite is installed.

# Usage:
PS > .\WinEventLogReport.ps1

# Purpose:

The goal of this script is the parse Windows Event Sysmon and Security logs for valuable information such as:
  * Executed binaries
  * Hashes of executed binaries
  * Security log event IDs
  * Logins
  * Failed logins
  * Invalid username logins
  * Domains used in successful AuthNs

A log file is generated and emailed per the specified smtp settings. Default values have been populated so the script must be edited to reflect your own email settings

# Credit

I was inspired to write the script when I stumbled up on the below link:
  * http://909research.com/windows-log-hunting-with-powershell/

I do not take credit for coming up with the commands. I threw them into a script for personal workstation monitoring.

Useful link for identifiying MS Security Log Event IDs:
  * https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/default.aspx
