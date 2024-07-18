@ECHO OFF
@setlocal enableextensions
@cd /d "%~dp0"
::
:: Name: configslavenodes.bat
::
:: Author: Arun Karunakaran
::
:: Origin: https://github.com/Arun-Karunakaran/devops.git
:: 
:: Func: This script will configure Jenkins slave node 
::       based on the input provide by the user
::       on any Windows platform.
::       By running this command the user will be 
::       able to create a jenkins slave node easily 
::       on the remote/local VM without the interruption
::       of the jenkins webconsole
::
:: Prerequisite:1. Need to be logged in to the remote/local VM
::               to perform this setup
::              2. jre1.8.0 as mimimum Java Runtime Environment
::              3. Go to Control Panel-> Programs -> Java(double click)-> Java Control Panel (Advanced)-> JNLP File Association -> Change to always allow
::              4. Jenkins Server setup (A Master node inorder to connect with slave)
::
:: Usage: configslavenodes.bat 
:: Usage prompt:
::              Username for Jenkins login? <username> 
::              Password for Jenkins? <password>
::              Mention the jenkins url you need to connect eg. http://<name>:8080? <http://jenkinsservername:8080>
::              Tell the node name you want to create? <nodename>
::              No of executors required? <1> or <2> or <n>
::              Specify full path for configuring node? eg. C:\Users\admin\Documents=> <path>
::
title ConfigJenkinsslavenodes
set /p username=Username for Jenkins login? 
set /p password=Password for Jenkins? 
set /p URL=Mention the jenkins url you need to connect eg. http://^<name^>:8080? 
set /p nodename=Tell the node name you want to create? 
set /p executors=No of executors required? 
set /p outputdir=Specify full path for configuring node? eg. C:\Users\admin\Documents=^> 
curl -u %username%:%password% %URL%/jnlpJars/agent.jar --output %outputdir%\agent.jar
curl -u %username%:%password% %URL%/jnlpJars/jenkins-cli.jar --output %outputdir%\jenkins-cli.jar
echo ^<?xml version="1.1" encoding="UTF-8"?^>^<slave^>^<name^>%nodename%^</name^>^<description^>^</description^>^<numExecutors^>%executors%^</numExecutors^>^<remoteFS^>%outputdir%^</remoteFS^>^<mode^>EXCLUSIVE^</mode^>^<retentionStrategy class="hudson.slaves.RetentionStrategy$Always"/^>^<launcher class="hudson.slaves.JNLPLauncher"^>^<workDirSettings^>^<disabled^>false^</disabled^>^<internalDir^>remoting^</internalDir^>^<failIfWorkDirIsMissing^>false^</failIfWorkDirIsMissing^>^</workDirSettings^>^</launcher^>^<label^>%nodename%^</label^>^<nodeProperties/^>^</slave^> > %outputdir%\node.xml
sleep 2
sc query | grep "SERVICE_NAME: jenkinsslave" > %outputdir%\scnamejenkins
FOR /F "tokens=* USEBACKQ" %%F IN (%outputdir%\scnamejenkins) DO (
SET result=%%F
)
echo %result:~14%
sc query %result:~14%
if %ERRORLEVEL% neq 1060 (
 	sc stop %result:~14% && sc delete %result:~14% )
sleep 2
taskkill /f /im "jp2launcher.exe"
sleep 2
java -jar %outputdir%\jenkins-cli.jar -s %URL%/ -auth %username%:%password% delete-node %nodename%
sleep 2
java -jar %outputdir%\jenkins-cli.jar -s %URL%/ -auth %username%:%password% create-node %nodename% < %outputdir%\node.xml
sleep 5
curl -u %username%:%password% %URL%/computer/%nodename%/slave-agent.jnlp --output %outputdir%\slave-agent.jnlp
curl -u %username%:%password% %URL%/jnlpJars/slave.jar --output %outputdir%\slave.jar
curl -u %username%:%password% %URL%/jnlpJars/jenkins-slave.exe --output %outputdir%\jenkins-slave.exe
sleep 2
start /WAIT /B javaws %outputdir%\slave-agent.jnlp &&^
sleep 10
