-- ============================================================================
-- PROJECT: Snowflake Weather Analytics Platform
-- DESCRIPTION: Master Deployment Script (01 to 09)
-- ============================================================================

-- Start Logging
!spool ./deployment_log.txt

!set variable_substitution=true;
!set stop_on_error=true;

SELECT 'DEPLOYMENT STARTED AT: ' || CURRENT_TIMESTAMP() AS log_entry;

-- 01: Setup Environment (Database, Schemas, Warehouse)
!source ./01_NOAA_WA_Create_DB_And_Schemas.sql;

-- 02: RBAC roles 
!source ./02_NOAA_WA_Create_Roles.sql;

-- 03: Marketplace Integration (NOAA Data Share) and Raw Layer (CTAS from Share)
!source ./03_NOAA_WA_Create_Raw_Setup.sql;

-- 04: Staging Layer (Cleaning & Typing)
!source ./04_NOAA_WA_Create_Staging_Setup.sql;

-- 05: Data Mart (Facts & Dimensions)
!source ./05_NOAA_WA_Create_Data_Mart_Setup.sql;

-- 06: Incremental Logic (Streams & Tasks)
!source ./06_NOAA_WA_Create_Tasks_Setup.sql;

-- 07: Analytics layer Views
!source ./07_NOAA_WA_Create_Analytics_Setup.sql;

-- 08: Analytics Layer (PII Tag based security)
!source ./08_NOAA_WA_PII_Masking_Policiews_Setup.sql;

-- 08: Analytics Layer (RLS-Enabled Views)
!source ./08_NOAA_WA_RLS_setup.sql;

-- 09: Automated Data Quality Monitoring 
!source ./09_NOAA_WA_Create_Monitoring_Setup.sql;

SELECT 'DEPLOYMENT COMPLETED SUCCESSFULLY AT: ' || CURRENT_TIMESTAMP() AS log_entry;

-- End Logging
!spool off;
