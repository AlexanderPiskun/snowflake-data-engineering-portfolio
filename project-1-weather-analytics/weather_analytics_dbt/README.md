# Weather Analytics Platform — dbt + Snowflake

## Overview
This project demonstrates a **production-style analytics engineering implementation** using **Snowflake** and **dbt Core** to transform raw weather data into **trusted, analytics-ready datasets**. 
The solution is designed to reflect **real-world enterprise patterns**, including layered data modeling, data quality enforcement, governance, security controls, and cost-efficient incremental processing.
The project uses **NOAA weather datasets** sourced from the **Snowflake Marketplace** and focuses on building a scalable analytics platform that supports BI, reporting, and downstream analytical use cases.

---

## Key Objectives
- Implement a **modern ELT analytics architecture** using Snowflake and dbt
- Transform raw external data into **curated, business-ready data marts**
- Enforce **data quality, governance, and security controls**
- Demonstrate **incremental processing patterns** for cost and performance efficiency
- Provide clear documentation suitable for **enterprise and regulated environments**

---

## Architecture Overview

**Data Flow:**

```
Snowflake Marketplace (NOAA)
        ↓
RAW Layer (Imported / External Data)
        ↓
STAGING Layer (Standardized & Cleaned)
        ↓
DATA_MART Layer (Dimensional Models)
        ↓
ANALYTICS Layer (Secure, Analytics-Ready Views)
```

### Layered Design
- **RAW**: External NOAA datasets accessed via Snowflake Marketplace using imported privileges
- **STAGING**: Cleaned, standardized, and type-safe transformations
- **DATA_MART**: Business-friendly dimensional models (fact & dimension tables)
- **ANALYTICS**: Secure consumption layer with row-level security and masking

This approach mirrors **enterprise dbt best practices** and supports long-term maintainability.

---

## Technologies Used

- **Snowflake** (Cloud Data Platform)
- **dbt Core** (SQL-based transformations)
- **Snowflake Streams & Tasks** (Incremental processing)
- **Snowflake Data Metric Functions (DMFs)** (Data quality monitoring)
- **GitHub** (Version control & documentation)

---

## Data Modeling

The project follows **dimensional modeling principles**:

- **Fact tables** capturing measurable weather observations
- **Dimension tables** describing locations, time, and weather attributes
- Clear separation between **raw ingestion** and **analytics consumption**

All models are:
- Documented
- Tested
- Version-controlled
- Designed for downstream BI and analytics

---

## Incremental Processing

To optimize performance and cost:

- Incremental models are implemented using **dbt incremental materializations**
- **Snowflake Streams & Tasks** are used where appropriate to capture data changes
- Only new or changed data is processed on each run

This significantly reduces compute usage while maintaining data freshness.

---

## Data Quality & Validation

Data quality is enforced using a combination of **dbt tests** and **Snowflake-native capabilities**:

### Implemented Checks
- Freshness validation
- Row count consistency
- Completeness checks
- Distribution and anomaly detection

### Snowflake DMFs
- Data Metric Functions are used to **continuously monitor data health**
- Results can be surfaced to monitoring dashboards or alerts

This approach aligns with **enterprise data observability standards**.

---

## Security & Governance

Security is implemented as a **first-class design principle**:

### Access Control
- Role-Based Access Control (RBAC)
- Separation of duties between engineering, analytics, and consumers

### Data Protection
- **Row-Level Security** using Row Access Policies
- **Tag-based Dynamic Data Masking** for sensitive attributes
- Object tagging to support data classification

### Governance
- Clear schema ownership and responsibilities
- Data lineage visible via Snowflake Snowsight and dbt documentation

These controls reflect **regulated industry best practices**.

---

## Analytics Consumption

The **ANALYTICS layer** provides:

- Secure, business-friendly views
- Consistent metrics and dimensions
- Optimized access for BI tools and ad-hoc analysis

Consumers interact only with governed, validated datasets — never raw data.

---

## Project Structure

```
project-1-weather-analytics/
├── models/
│   ├── staging/
│   ├── marts/
│   └── analytics/
├── macros/
├── tests/
├── snapshots/
├── dbt_project.yml
└── README.md
```

---

## Key Learning Outcomes

This project demonstrates:

- End-to-end analytics engineering using **Snowflake + dbt**
- Production-ready data modeling and transformation patterns
- Data quality monitoring using Snowflake DMFs
- Secure analytics delivery using masking and row-level security
- Cost-efficient incremental processing strategies
- Clear documentation and maintainable project structure

---

## Intended Audience

This project is designed for:

- Data Engineers
- Analytics Engineers
- Cloud Data Platform Engineers
- Hiring Managers evaluating Snowflake / dbt expertise

---

## How to Run This Project Locally

### Prerequisites
- Snowflake account with access to the **NOAA Marketplace dataset**
- Python 3.9+
- dbt Core (Snowflake adapter)
- Git

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/AlexanderPiskun/snowflake-data-engineering-portfolio.git
cd project-1-weather-analytics
```

2. **Create and activate a virtual environment**
```bash
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
```

3. **Install dbt dependencies**
```bash
pip install dbt-snowflake
```

4. **Configure `profiles.yml`**

Example Snowflake profile:
```yaml
weather_analytics:
  target: dev
  outputs:
    dev:
      type: snowflake
      account: <account>
      user: <user>
      password: <password>
      role: <role>
      database: WEATHER_DB
      warehouse: TRANSFORMING_WH
      schema: DBT_DEV
      threads: 4
```

5. **Run dbt**
```bash
dbt deps
dbt build
dbt test
dbt docs generate
dbt docs serve
```

---

## Data Lineage & Observability

### Lineage
- End-to-end lineage is available through **dbt documentation** and **Snowflake Snowsight**
- Each analytics object can be traced back to its RAW NOAA source tables

### Observability
- **Snowflake Data Metric Functions (DMFs)** monitor freshness, volume, and distribution
- Test failures and anomalies are visible through queryable system tables
- This enables proactive detection of data quality issues before BI impact

---

## Security & Governance Highlights (Recruiter-Focused)

This project intentionally mirrors **regulated enterprise environments**:

- Schema-level separation (RAW / STAGING / DATA_MART / ANALYTICS)
- RBAC enforcing least-privilege access
- Row Access Policies restricting data by geographic region
- Tag-based Dynamic Data Masking for simulated sensitive attributes
- Object tagging supporting data classification and governance workflows

These patterns are directly applicable to **financial services, insurance, and fintech platforms**.

---

## dbt Project Design & Best Practices

### Naming & Structure
- Models follow clear, purpose-driven naming conventions
- Folder structure reflects transformation intent and data lifecycle

### Testing
- dbt tests validate:
  - Freshness
  - Completeness
  - Uniqueness
  - Referential integrity

### Documentation
- All models include descriptions and column-level metadata
- dbt Docs provide searchable, version-controlled documentation

### Incremental Strategy
- Incremental materializations used for large fact tables
- Streams & Tasks reduce compute cost and improve scalability

---

## Screenshots & Portfolio Checklist

- dbt Docs serve project tree
- dbt build and test execution output

---

## Future Enhancements

Potential next steps include:

- Automated CI/CD pipelines for dbt deployments
- Data quality alerting and SLA monitoring
- Integration with BI tools (Power BI / Tableau)
- Expanded weather analytics use cases

---

## Author

**Alexander Piskun**  
Senior Oracle & Cloud Database Administrator / Analytics Engineer  
LinkedIn: https://www.linkedin.com/in/alexanderpiskun  
GitHub: https://github.com/AlexanderPiskun

---

## Disclaimer

This project uses publicly available NOAA datasets and is intended for **demonstration and educational purposes only**.

