$Desktop = [Environment]::GetFolderPath("Desktop")
$Date = Get-Date -UFormat "%d-%m-%Y"
$Folder = "$Desktop\Event Logs"
$Path = "$Folder\Log_$Date.log"

$EmailFrom = "script@YourDomain.com"
$EmailTo = "you@YourDomain.com"
$Subject = "Windows Event Log Report"
$Body = "Please see attachments"
$SMTPServer = "smtp.gmail.com"
$User = "you@YourDomain.com"
$PWord = ConvertTo-SecureString –String "<Your Email Password>" –AsPlainText -Force
$Credential = New-Object –TypeName "System.Management.Automation.PSCredential" –ArgumentList $User, $PWord



if (Test-Path $Folder){
Write-Host "Folder already exists. Continuing..."
}else{
Write-host "Creating folder..."
new-item $Folder -itemtype directory | Out-Null
}

Try
{
    #Get list of executed images recorded by sysmon
    Write-Host "Getting executed images..."
    echo "//EXECUTED IMAGES//" >> $Path
    Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=1} | %{$_.Properties[3].Value} | sort -Unique >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
} 

Try {    
    #Get list of hashes of ever executable run
    Write-Host "Getting hashes of executed images..."
    echo "//IMAGE HASHES EXECUTED//" >> $Path
    Get-WinEvent -filterhashtable @{logname="Microsoft-Windows-Sysmon/Operational";id=1} | %{$_.Properties[11].Value}| sort -Unique >> $Path
    eecho "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
}

Try {
    #Get list of all security log event IDs
    Write-Host "Gettings security log event IDs..."
    echo "//SECURITY LOG IDs//" >> $Path
    Get-WinEvent -FilterHashtable @{logname="security"}| Group-Object id -NoElement | sort count >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
}

Try {
    #Get count of logins by username
    Write-host "Getting count of logins by usernames..."
    echo "//LOGIN COUNT//" >> $Path
    Get-WinEvent -FilterHashtable @{logname="security";id=4624} | %{$_.Properties[5].Value} | group-object -noelement | sort count >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
}

Try {
    #Get failed login count
    Write-Host "Getting failed logins count..."
    echo "//FAILED LOGINS//" >> $Path
    Get-WinEvent -FilterHashtable @{logname="security";id=4625} -ErrorAction SilentlyContinue | %{$_.Properties[1].Value} | Group-Object -noelement >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    if ($ErrorMessage){
        Write-Host "No failed logins found"
    }
    Continue
}

Try {
    #Get invalid usernames used for login
    Write-Host "Getting invalid usernames used for login..."
    echo "//INVALID USERNAMES//" >> $Path
    Get-WinEvent -FilterHashtable @{logname="security";id=4776} -ErrorAction SilentlyContinue | %{$_.Properties[1].Value} | sort -Unique >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    if ($ErrorMessage){
        Write-Host "No failed logins found"
    }
    Continue
}

Try {
    #Get domains for accounts that have logged in
    Write-host "Getting domains of logged-on accounts..."
    echo "//DOMAINS//" >> $Path
    echo "" >> $Path
    Get-WinEvent -FilterHashtable @{logname="security";id=4624} | %{$_.Properties[6].Value} | sort -Unique >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
}

Try {
    #Get usernames that have logged on
    Write-host "Getting usernames that have logged on..."
    echo "//AUTHENTICATED USER ACCOUNTS//" >> $Path
    echo "" >> $Path
    Get-WinEvent -FilterHashtable @{logname="security";id=4624} | %{$_.Properties[5].Value} | sort -Unique >> $Path
    echo "//================================================================//" >> $Path
    echo "" >> $Path
} Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
}

Finally
{
    Write-Host $_ -ForegroundColor Yellow "[+]This script created a folder on your Desktop called 'Event Logs' with the results."
    Send-MailMessage -SmtpServer $SMTPServer -Port 587 -UseSsl -Credential $Credential -From $EmailFrom -To $EmailTo -Subject $Subject -Attachments $Path -Body "Please find attached Windows Events Log Report."
}