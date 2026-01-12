@echo off
:: ============================================================================
:: Windows Deployment Launcher for Snowflake Project
:: ============================================================================

set /p ACCOUNT="Enter Snowflake Account (e.g. xy12345.east-us-2): "
set /p USERNAME="Enter Snowflake Username: "

echo Starting Deployment...
echo Logging details to full_execution_details.log...

:: Call SnowSQL
:: -f: executes the master script
:: -o: creates a detailed technical log for the session
snowsql -a %ACCOUNT% -u %USERNAME% -f NOAA_WA_Deploy_All.sql -o output_file=./full_execution_details.log

echo.
echo Deployment Process Finished. Please check deployment_log.txt and full_execution_details.log.
pause	
