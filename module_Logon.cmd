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

SET Name=module_logon
SET Version=1.0.0
SET BUILD=2019-12-13 0743
Title %Name% Version: %Version%
Prompt mL$G
color 8F
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Declare Global variables
:: All User variables are set within here.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Defaults
::	uses Public folder 
SET $LogPath=\\Sc-Vanadium\Logs\module_Logon
SET $Log=module_logon.log

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::##### Everything below here is 'hard-coded' [DO NOT MODIFY] #####
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Make sure temp directories exist
IF NOT EXIST "%TEMP%\var" MD "%TEMP%\var"

:: Headers
:: ISO-Date ; Time ; Computer ; User ; User-UPN ; FullName

:: Get ISO-Date
@powershell Get-Date -format "yyyy-MM-dd" > "%TEMP%\var\var_ISO8601_Date.txt"
SET /P $ISO_DATE= < "%TEMP%\var\var_ISO8601_Date.txt"

:: Get User full name
FOR /F "skip=3 tokens=2 delims=^=" %%P IN ('wmic NETLOGIN GET FullName /Value') DO SET "$FULLNAME=%%P"

:: Get User UPN
whoami /UPN > "%TEMP%\var\var_User_UPN.txt"
SET /P $USER_UPN= < "%TEMP%\var\var_User_UPN.txt"

:: remove the leading space in TIME
for /f "delims=. " %%P IN ("%TIME%") do echo %%P> "%TEMP%\var\var_Time.txt"
SET /P $TIME= < "%TEMP%\var\var_Time.txt"

:: Write out to log
IF EXIST "%$LogPath%" ECHO %$ISO_DATE%;%$TIME%;%COMPUTERNAME%;%USERNAME%;%$USER_UPN%;%$FULLNAME% >> "%$LogPath%\%$Log%"

:EOF
ENDLOCAL
EXIT


