#!/bin/bash
# ============================================================================
# macOS/Linux Deployment Launcher for Snowflake Project
# ============================================================================

read -p "Enter Snowflake Account (e.g. xy12345.east-us-2): " ACCOUNT
read -p "Enter Snowflake Username: " USERNAME

echo "Starting Deployment..."

# Call SnowSQL
snowsql -a "$ACCOUNT" -u "$USERNAME" -f NOAA_WA_Deploy_All.sql -o output_file=./full_execution_details.log

echo ""
echo "Deployment Process Finished. Check deployment_log.txt for results."
