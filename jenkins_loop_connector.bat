@echo off
title Jenkins Agent Connected ... DO NOT CLOSE THIS WINDOW
set host=%COMPUTERNAME%
REM LOAD PROPERTIES ----------------------------------------------------------------------------
FOR /F "tokens=1,2 delims==" %%G IN (jenkins.properties) DO (set %%G=%%H)
REM --------------------------------------------------------------------------------------------

for /f "skip=4 usebackq tokens=2" %%a in (nslookup %master_name%) do ( if %%a NEQ %master_name% set IP=%%a)
echo %IP%


:loop
NetStat -na | Findstr "%IP%:%port%"| findstr "ESTABLISHED"
IF %ERRORLEVEL% equ 0 (
echo CONNECTION ALREADY ESTABLISHED.. DO NOT CLOSE THIS WINDOW...
timeout /t 300 /nobreak
goto loop
)

IF %ERRORLEVEL% equ 1 (

"%java_path%" -Dorg.jenkinsci.plugins.gitclient.Git.timeOut=1100 -jar agent.jar -jnlpUrl https://%master_name%:8443/computer/%host%/jenkins-agent.jnlp -secret 29f8590b8be9b1940fa179cc8c1667036bde4c7691ceb6b63045dad6264fef3b -workDir "C:\Jenkins"
timeout /t 15 /nobreak
goto loop
)
