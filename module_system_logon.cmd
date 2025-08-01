:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Author:		David Geeraerts
:: Location:	Olympia, Washington USA
:: E-Mail:		dgeeraerts.evergreen@gmail.com
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Copyleft License(s)
:: GNU GPL (General Public License)
:: https://www.gnu.org/licenses/gpl-3.0.en.html
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

::::::::::::::::::::::::::::::::::
:: VERSIONING INFORMATION		::
::  Semantic Versioning used	::
::   http://semver.org/			::
::	Major.Minor.Revision		::
::::::::::::::::::::::::::::::::::

::#############################################################################
::							#DESCRIPTION#
:: Logon script intented to capture usage metrics based on user log on.
::	Script should be configured to run on logon, either configured locally
::	or with Group Policy	
::	
::#############################################################################

@Echo Off
@SETLOCAL enableextensions
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

SET $Name=module_system_logon
SET $Version=1.3.3
SET $BUILD=20250731 1230
Title %$Name% Version: %$Version%
Prompt mL$G
color 8F
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
:: All User variables are set within here.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Defaults
::	Log name
SET $Log=module_logon.log

::	Logging server to ship log
SET $LogPath=\\Sc-Tellus\Logs\module_Logon

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Make sure temp directories exist
::	write to temp first, then over network.
IF NOT EXIST "%TEMP%\var" MD "%TEMP%\var"
IF NOT EXIST "%APPDATA%\%$Name%" MD "%APPDATA%\%$Name%"
:: Headers
:: ISO-Date ; Time ; Computer ; SessionName; User ; User-UPN ; FullName
SET "$HEADERS=ISO-Date ; Time ; Computer ; SessionName; User ; User-UPN ; FullName"
IF NOT EXIST "%APPDATA%\%$Name%\%$Log%" echo # %$HEADERS% > "%APPDATA%\%$Name%\%$Log%"

:: Get ISO-Date
@powershell Get-Date -format "yyyy-MM-dd" > "%TEMP%\var\var_ISO8601_Date.txt"
SET /P $ISO_DATE= < "%TEMP%\var\var_ISO8601_Date.txt"

:: Get User full name
:: WMIC is getting deprecated
::FOR /F "skip=3 tokens=2 delims=^=" %%P IN ('wmic NETLOGIN GET FullName /Value') DO SET "$FULLNAME=%%P"
@powershell -command "(Get-WmiObject -Class Win32_NetworkLoginProfile | Select-Object -Property FullName)"> "%TEMP%\var\Full_Name.txt"
IF EXIST "%TEMP%\var\Full_Name_dirty.txt" del /F /Q "%TEMP%\var\Full_Name_dirty.txt"
FOR /F "skip=4 tokens=1 delims=" %%P IN (%TEMP%\var\Full_Name.txt) DO echo %%P >> "%TEMP%\var\Full_Name_dirty.txt"
findstr /v /C:"ECHO is off." "%Temp%\var\Full_Name_dirty.txt" > "%TEMP%\var\Full_Name_clean.txt"
REM Some full name queries have additional text as additional lines.
:: FOR /F "tokens=1 delims=" %%P IN (%TEMP%\var\Full_Name_clean.txt) DO SET $FULLNAME=%%P
:: This will only take the first line and ignore additional lines
SET /P $FULLNAME= < "%TEMP%\var\Full_Name_clean.txt"

:: Get User UPN
whoami /UPN > "%TEMP%\var\var_User_UPN.txt"
SET /P $USER_UPN= < "%TEMP%\var\var_User_UPN.txt"

:: Get the active user
query user | find ">"> "%TEMP%\var\var_Active_User.txt"

:: Get SessionName
FOR /F "tokens=2 delims= " %%P IN (%TEMP%\var\var_Active_User.txt) DO echo %%P> "%TEMP%\var\var_SessionName.txt"
SET /P $SESSIONNAME= < "%TEMP%\var\var_SessionName.txt"

:: remove the leading space in TIME
for /f "delims=. " %%P IN ("%TIME%") do echo %%P> "%TEMP%\var\var_Time.txt"
SET /P $TIME= < "%TEMP%\var\var_Time.txt"

:: Write out locally
ECHO %$ISO_DATE%;%$TIME%;%COMPUTERNAME%;%$SESSIONNAME%;%USERNAME%;%$USER_UPN%;%$FULLNAME% >> "%APPDATA%\%$Name%\%$Log%"
:: Write out to logging server
IF EXIST "%$LogPath%" ECHO %$ISO_DATE%;%$TIME%;%COMPUTERNAME%;%$SESSIONNAME%;%USERNAME%;%$USER_UPN%;%$FULLNAME% >> "%$LogPath%\%$Log%"

:End
ENDLOCAL
EXIT


