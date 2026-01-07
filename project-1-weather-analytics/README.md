# 🌨️ Snowflake NOAA Weather Data Pipeline

## 📌 SQL files Order execution: 
   01_NOAA_WA_.. -> 08_NOAA_WA_..

## 📌 Project Overview
This project demonstrates a **production‑grade Snowflake data integration and analytics pipeline** built using **public NOAA datasets from the Snowflake Marketplace**. The goal is to showcase hands‑on experience with:

- Snowflake SQL & SnowPro‑level concepts
- RBAC‑aware data engineering with Row-level security  
- Task‑ and stream‑based orchestration
- Layered data architecture (RAW → STAGING → DATA_MART → ANALYTICS)
- Analytics‑ready fact and dimension modeling

The project is designed as a **portfolio‑ready reference implementation** for a **Senior Data Engineer / DBA** with strong cloud data platform expertise.

---

## 🧱 Architecture Overview

```
SNOWFLAKE_PUBLIC_DATA_FREE (Marketplace Share)
              ↓
          RAW (Local Tables)
              ↓
        STAGING (Cleaned & Typed)
              ↓
      DATA_MART (Facts & Dims & Analytics)
	            ↓
      ANALYTICS (Business-facing views + RLS)
	            ↓
      Consumers (Roles)
```

### Why This Architecture?
- Clear separation of concerns
- Supports incremental processing
- RBAC‑safe and task‑friendly
- Mirrors real enterprise Snowflake deployments

---

## 📂 Data Sources (Snowflake Marketplace)

The pipeline is built on **free NOAA datasets** available via the Snowflake Marketplace:

- `NOAA_WEATHER_METRICS_TIMESERIES`
- `NOAA_WEATHER_STATION_INDEX`
- `NOAA_NWRFC_WATER_SUPPLY_TIMESERIES`

These datasets are exposed via the **`SNOWFLAKE_PUBLIC_DATA_FREE` share** under the `PUBLIC_DATA_FREE` schema.

---

## ⚠️ Important Design Decision: RAW Layer Uses TABLES (Not Views)

### ❓ Why not create RAW views over Marketplace objects?

Initially, the RAW layer was designed using **views** that directly referenced Marketplace objects, for example:

```sql
CREATE VIEW RAW.NOAA_WEATHER_METRICS_TS AS
SELECT *
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.NOAA_WEATHER_METRICS_TIMESERIES;
```

However, this approach **breaks task execution** under a non‑admin role.

---

### 🚨 The Core Issue: Imported Privileges

- Marketplace databases are **imported from a data share**
- Privileges on shared databases are controlled **only by the data provider**
- Consumer accounts **cannot grant `USAGE` or `IMPORTED PRIVILEGES`** unless explicitly allowed
- In this case, the provider **did not expose imported privileges**

As a result:
- Interactive `SELECT` queries worked
- **Snowflake TASK execution failed**, even when:
  - Task owner was correct
  - Schema and warehouse privileges were granted

Snowflake tasks execute **server‑side** and require **direct access to all underlying objects**, not just the top‑level view.

---

### ✅ Solution: Materialize RAW Layer as Local Tables

To ensure reliable, RBAC‑safe execution, the RAW layer was redesigned to use **local tables** populated from Marketplace data:

```sql
CREATE OR REPLACE TABLE RAW.NOAA_WEATHER_METRICS_TS AS
SELECT *
FROM SNOWFLAKE_PUBLIC_DATA_FREE.PUBLIC_DATA_FREE.NOAA_WEATHER_METRICS_TIMESERIES;
```

#### Benefits of This Approach
- ✅ Tasks execute successfully under `NOAA_ENGINEER` role
- ✅ No dependency on imported privileges
- ✅ Full ownership and RBAC control
- ✅ Better isolation from Marketplace changes
- ✅ More realistic enterprise pattern

> This mirrors real‑world Snowflake deployments, where external or shared data is **snapshotted into internal RAW tables** before further processing.

---

## 🗂️ Data Layers Explained

### 🟦 RAW Layer
**Purpose:** Snapshot ingestion from Marketplace

- Local tables created via `CREATE TABLE AS SELECT`
- Represents source‑aligned data
- Reloaded periodically (snapshot pattern)

Key objects:
- `RAW.NOAA_WEATHER_METRICS_TS`
- `RAW.NOAA_WEATHER_STATION_INDEX`
- `RAW.NOAA_WATER_SUPPLY_TS`

---

### 🟨 STAGING Layer
**Purpose:** Data cleansing and standardization

- Explicit data conversion (casting)
- Column renaming
- Load timestamps

Example:
```sql
CREATE OR REPLACE VIEW STAGING.V_STG_WEATHER_METRICS AS
SELECT
  station_id,
  metric_name,
  observation_date::DATE AS observation_date,
  metric_value::FLOAT AS metric_value,
  CURRENT_TIMESTAMP AS load_ts
FROM RAW.NOAA_WEATHER_METRICS_TS;
```

---

### 🟩 DATA_MART Layer
**Purpose:** Aggregated fact and dim tables

- Incremental processing using **STREAMS + TASKS**
- Aggregated facts and dims


Key objects:
- `DATA_MART.FACT_WEATHER_INPUT`
- `DATA_MART.FACT_WEATHER_DAILY`
- `DATA_MART.DIM_STATION`

---
### 🟩 ANALYTICS Layer
**Purpose:** Analytics Layer (Consumption Layer) with Row-Level Security (RLS)
The ANALYTICS schema represents the **semantic / consumption layer** of the platform. 
It exposes **read-only views** built on top of curated DATA_MART tables and is designed for:

- BI tools (Power BI, Tableau, Looker, etc.)
- Data analysts and business users
- External consumers with limited privileges

This layer intentionally contains **no physical tables** — only views and security policies.

Key objects:
- `ANALYTICS.AVG_TEMP_BY_STATE`
- `ANALYTICS.TEMP_VARIABILITY`
- `ANALYTICS.EXTREME_TEMP_DAYS`
- `ANALYTICS.TOP_10_WARMEST_STATIONS`

---


## 🔄 Orchestration & Incremental Processing

### Tasks
- Snapshot loads for RAW and STAGING
- Incremental fact building using streams

### Tasks flow:
```
TASK_LOAD_STAGING_WEATHER (root task)
    ↓ (overwrite)
 TASK_LOAD_FACT_INPUT (child task, executed after TASK_LOAD_STAGING_WEATHER)
    ↓ (overwrite)
 STREAM detects changes 
    ↓
 TASK_BUILD_FACT_WEATHER_DAILY (child task, executed after TASK_LOAD_FACT_INPUT)
    (runs ONLY if stream has data)
```

### Streams
- Track changes after snapshot reloads
- Enable efficient downstream processing

Example guard:
```sql
WHEN SYSTEM$STREAM_HAS_DATA('FACT_WEATHER_INPUT_STREAM')
```

This ensures:
- No unnecessary warehouse usage
- Exactly‑once processing semantics

---

## 🔐 RBAC Model

| Role                    | Responsibilities                                                                |
|-------------------------|---------------------------------------------------------------------------------|
| `ACCOUNTADMIN`          | Marketplace setup, warehouse, database and roles creation                       |
| `NOAA_ENGINEER`         | Owns tables, views, streams, tasks                                              |
| `NOAA_ANALYST`          | Read-only access to ANALYTICS schema                                            |
| `NOAA_ANALYST_WEST`     | Read-only access to ANALYTICS schema + allowed to see WEST states only (RLS)    |
| `NOAA_ANALYST_CENTRAL`  | Read-only access to ANALYTICS schema + allowed to see CENTRAL states only (RLS) |
| `NOAA_ANALYST_EAST`     | Read-only access to ANALYTICS schema + allowed to see EAST states only (RLS)    |


The project strictly follows **least-privilege principles** and enforces a **clear separation between physical data models and business consumption**.

---

## 🧭 Formal Design Decision: ANALYTICS Schema as the Consumption Layer

### Decision
Create a dedicated **`ANALYTICS` schema** containing business-facing views built on top of `DATA_MART`, and grant read-only access to analytics users **only** on this schema.

### Rationale
- Decouples consumers from physical fact/dimension tables
- Enables safe refactoring of `DATA_MART`
- Simplifies RBAC and auditing
- Centralizes governance logic (RLS, masking, semantic naming)
- Mirrors enterprise data platform best practices

### Consequences
- Analysts interact only with curated, stable views
- Engineering retains full control over data modeling
- Security policies can evolve without breaking dashboards

This schema acts as the **data contract** between data engineering and analytics.

---

## 🔒 Row-Level Security (RLS) Examples

Row-level security is implemented using Snowflake Row Access Policies applied to ANALYTICS views.
Access decisions are evaluated dynamically based on the current role and a centralized role-to-state mapping table.
This design enforces least privilege while preserving a single reusable DATA_MART layer.


### Example : State-Based Access Control

#### Mapping Table
```sql
CREATE OR REPLACE TABLE SECURITY.STATE_ACCESS_MAP (
  role_name STRING,
  state STRING
);
```

```sql
INSERT INTO SECURITY.STATE_ACCESS_MAP VALUES
  ('NOAA_ANALYST_WEST', 'California'),
  ('NOAA_ANALYST_WEST', 'Washington'),
  ('NOAA_ANALYST_CENTRAL', 'Arkansas'),
  ('NOAA_ANALYST_CENTRAL', 'Illinois'),
  ('NOAA_ANALYST_EAST', 'Alabama'),
  ('NOAA_ANALYST_EAST', 'Connecticut'),
  .
  .
  .
```

#### Row Access Policy
```sql
CREATE OR REPLACE ROW ACCESS POLICY SECURITY.STATE_RLP
AS (p_state STRING) RETURNS BOOLEAN ->
     'NOAA_ANALYST' = CURRENT_ROLE() 
  OR 'NOAA_ENGINEER' = CURRENT_ROLE()
  OR EXISTS (
      SELECT 1
      FROM SECURITY.STATE_ACCESS_MAP
      WHERE role_name = CURRENT_ROLE()
        AND state = p_state
    );
```

#### Apply Policy to ANALYTICS View
```sql
ALTER VIEW ANALYTICS.V_AVG_TEMP_BY_STATE
ADD ROW ACCESS POLICY SECURITY.STATE_RLP ON (state);
```

---

### Why RLS Is Applied at the ANALYTICS Layer

- Avoids contaminating core fact tables
- Keeps DATA_MART reusable for multiple consumers
- Allows different security rules per use case
- Matches Snowflake governance best practices

### Key Takeaway
> Security policies belong at the **presentation boundary**, not in the physical storage layer.
  This design ensures scalability, governance, and long-term maintainability of the Snowflake platform.

---


## 📊 Example Analytics

- Average temperature by state
- Daily weather metrics by station
- Time‑series trend analysis
- Extreme Weather Days
- Top 10 Warmest Stations

Example:
```sql
SELECT *
FROM DATA_MART.AVG_TEMP_BY_STATE
ORDER BY avg_temperature DESC;
```

---

## 🎯 Skills Demonstrated

- Snowflake Marketplace integration
- Secure RBAC design
- Task & stream orchestration
- Snapshot + incremental hybrid pipelines
- Dimensional modeling
- Cost‑aware execution patterns

---

## 🏁 Final Notes

This project intentionally prioritizes **correct, production-grade Snowflake engineering patterns** over convenience or shortcuts.

### Why RAW Tables Instead of Views or Dynamic Tables?

The NOAA datasets are consumed from the Snowflake Marketplace via the `SNOWFLAKE_PUBLIC_DATA_FREE` share. 
While Snowflake offers powerful abstractions such as **views** and **dynamic tables**, neither is suitable in this specific scenario for task-driven pipelines under strict RBAC:

#### 1️ Shared Marketplace Objects & Imported Privileges
- Marketplace databases are **shared** and governed by the data provider
- The consumer account cannot grant `USAGE` or `IMPORTED PRIVILEGES` unless explicitly exposed by the provider
- In this case, imported privileges were **not available**
- As a result, Snowflake **TASKS cannot reliably execute** when sourcing data directly from shared objects (even via local views)

Materializing the data into local RAW tables ensures:
- Full ownership and privilege control
- Reliable server-side task execution
- Isolation from cross-account privilege constraints

#### 2️ Why Not Dynamic Tables?

Dynamic tables require **CHANGE_TRACKING = TRUE** on all upstream source objects.

- The shared Marketplace views **do not have change tracking enabled**
- Change tracking **cannot be enabled by the consumer** on shared objects
- Therefore, dynamic tables **cannot be used** with these datasets

This makes dynamic tables unsuitable for this project despite their advantages in other scenarios.

#### 3️ Final Architectural Choice

Given these constraints, the RAW layer was intentionally designed using:

- `CREATE TABLE AS SELECT` (snapshot ingestion)
- Periodic reloads aligned with Marketplace data refresh cadence
- Downstream incremental processing using **STREAMS + TASKS** on locally owned tables

This approach is:
- ✅ RBAC-safe
- ✅ Task-compatible
- ✅ Transparent and auditable
- ✅ Aligned with real-world enterprise Snowflake practices

> The decision to materialize Marketplace data into RAW tables is a **deliberate architectural choice**, 
  reflecting a deep understanding of Snowflake security, task execution semantics, and shared data limitations — not a workaround.

---

📌 **Author:** Alexander Piskun  
📜 **Certification:** Snowflake SnowPro Core  
☁️ **Focus:** Data Engineering · Cloud Databases · Analytics Platforms
