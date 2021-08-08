$servers = import-csv -path ".\servers.csv" -Delimiter ";"
$installCommands = ".\installcommands.ps1"
$PSExec = "C:\Windows\System32\PSExec.exe"
$successlog = ".\success.csv"



Write-Host 'Enabling WinRM on local machine'
Enable-PSRemoting -Force –SkipNetworkProfileCheck
Restart-Service WinRM
#Start-Process -Filepath "winrm" -ArgumentList "quickconfig" -Wait

$servers | ForEach-Object -Parallel {
    $server=$_
    Write-Host ('Processing server '+$($server.servername))

    $password = ConvertTo-SecureString $($server.pass) -AsPlainText -Force
    $sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
    $Creds = New-Object System.Management.Automation.PSCredential ($($server.user), $password)
    #"добавить компьютер назначения к значениям параметра конфигурации TrustedHosts. "
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value $($server.servername) -Force

    # #Включить WinRM
    # Write-Host 'Enabling WinRM on remote host with psexec'
    # Start-Process -Filepath "$PSExec" -ArgumentList "\\$($server.servername) -u $($server.user) -p $($server.pass) -h -s  -accepteula -nobanner powershell.exe Enable-PSRemoting –SkipNetworkProfileCheck -Force; Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -RemoteAddress Any" -NoNewWindow -Wait

    switch ($($server.conntype)) {
        "secure" { 
            Write-Host "Open secure WinRM session on remote host $($server.servername)"
            $session = New-PSSession -ComputerName $($server.servername) -Credential $Creds -UseSSL -SessionOption $sessionOption -ErrorAction SilentlyContinue }
        "insecure" { 
            Write-Host "Open insecure WinRM session on remote host $($server.servername)"
            $session = New-PSSession -ComputerName $($server.servername) -Credential $Creds -ErrorAction SilentlyContinue  }
    }
    
    if (!$session) {
        Write-Host "Can't connect to remote computer $($server.servername)"
        break
    }
    else {
        Write-Host "Invoking commands on remote host $($server.servername)"
        $result = Invoke-Command -Session $session -FilePath $($Using:installCommands)
        if ($result) {
            $softName = $result.Name
            Add-content $($Using:successlog) -Value "$($server.servername);$softName"
            Write-Host "Successfully installed software $softName on $($server.servername)"
        } 
        else {
            Add-content $($Using:successlog) -Value "$($server.servername);fail!!!"
            Write-Host "Error installing software on $($server.servername)"
        }
    }
    
} -ThrottleLimit 10