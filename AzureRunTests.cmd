@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: AzureRunTests ^<relative path to .csproj file^>
	goto exit
)

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\packages\NUnit.Runners.2.6.3\tools\nunit-console" %1 /config=Release /framework=net-4.5

:exit
exit /b %ERRORLEVEL%