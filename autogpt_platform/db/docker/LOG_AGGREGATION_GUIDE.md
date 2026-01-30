# Log Aggregation Guide for Supabase

This guide explains how to deploy and use the Loki + Promtail log aggregation stack for centralized logging of your Supabase self-hosted deployment.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Deployment](#deployment)
4. [Querying Logs](#querying-logs)
5. [Log Retention](#log-retention)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Overview

### What is Loki?

Grafana Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus. Unlike other logging systems, Loki:

- **Indexes only metadata** (labels), not log contents, making it extremely cost-effective
- **Uses the same labels** as Prometheus for consistency
- **Integrates seamlessly** with Grafana for unified metrics and logs
- **Requires minimal configuration** compared to Elasticsearch/ELK

### What is Promtail?

Promtail is the agent responsible for:

- Discovering log sources (Docker containers, files)
- Attaching labels to log streams
- Shipping logs to Loki

### Benefits

✅ **Centralized Logging**: All Supabase service logs in one place
✅ **30-Day Retention**: Automated log retention management
✅ **Full-Text Search**: Query logs across all services
✅ **Correlation**: Link logs with metrics in Grafana
✅ **Low Overhead**: Minimal resource consumption
✅ **Docker Native**: Automatic discovery of container logs

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Grafana                              │
│  (Visualization & Querying - Port 3001)                 │
└────────────────┬────────────────────────────────────────┘
                 │
                 │ Queries
                 ├──────────────┬─────────────────┐
                 │              │                 │
     ┌───────────▼──────┐  ┌────▼─────┐  ┌───────▼────────┐
     │   Prometheus     │  │   Loki   │  │  (Future: Tempo)│
     │  (Metrics)       │  │  (Logs)  │  │  (Traces)       │
     └──────────────────┘  └────┬─────┘  └─────────────────┘
                                │
                                │ Receives logs
                                │
                         ┌──────▼──────┐
                         │  Promtail   │
                         │ (Log Agent) │
                         └──────┬──────┘
                                │
                                │ Collects logs
                                │
         ┌──────────────────────┼──────────────────────┐
         │                      │                      │
    ┌────▼────┐          ┌──────▼──────┐      ┌───────▼──────┐
    │  Auth   │          │     DB      │      │   Storage    │
    │  Logs   │          │    Logs     │      │    Logs      │
    └─────────┘          └─────────────┘      └──────────────┘
                    (and all other services)
```

---

## Deployment

### Step 1: Ensure Monitoring Stack is Running

The log aggregation stack extends the existing monitoring infrastructure:

```bash
cd /path/to/autogpt_platform/db/docker

# Start base Supabase services
docker compose up -d

# Start monitoring stack (includes Loki + Promtail)
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml up -d
```

### Step 2: Verify Deployment

```bash
# Check all monitoring services are running
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml ps

# Verify Loki is healthy
curl http://localhost:3100/ready
# Should return: ready

# Verify Promtail is shipping logs
curl http://localhost:9080/ready
# Should return: ready
```

### Step 3: Access Grafana

1. Open browser to: http://localhost:3001
2. Login with credentials:
   - Username: `admin`
   - Password: `admin` (or value of `GRAFANA_ADMIN_PASSWORD` env var)
3. Navigate to **Configuration** → **Data Sources**
4. Verify **Loki** datasource is present

---

## Querying Logs

### LogQL Basics

LogQL is Loki's query language, similar to PromQL for Prometheus.

**Basic query structure:**

```logql
{label="value"} |= "search string"
```

### Common Queries

#### View all logs from auth service

```logql
{service="auth"}
```

#### Search for errors across all services

```logql
{service=~".*"} |= "ERROR"
```

#### View PostgreSQL logs only

```logql
{service="db"}
```

#### Filter by log level

```logql
{service="auth"} | json | level="ERROR"
```

#### Search for specific user activity

```logql
{service="auth"} |= "user_id" | json | user_id="123e4567-e89b-12d3-a456-426614174000"
```

#### View Kong API Gateway access logs

```logql
{service="kong"} | logfmt | status >= 400
```

#### Exclude health check noise

```logql
{service="auth"} != "health"
```

### Log Stream Selectors

| Selector | Description | Example |
|----------|-------------|---------|
| `{label="value"}` | Exact match | `{service="auth"}` |
| `{label=~"regex"}` | Regex match | `{service=~"auth|db"}` |
| `{label!="value"}` | Not equal | `{service!="studio"}` |
| `{label!~"regex"}` | Regex not match | `{service!~"imgproxy|vector"}` |

### Log Pipeline Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `|= "text"` | Contains text | `|= "ERROR"` |
| `!= "text"` | Does not contain | `!= "health"` |
| `|~ "regex"` | Regex match | `|~ "ERROR|WARN"` |
| `!~ "regex"` | Regex not match | `!~ "DEBUG|INFO"` |
| `| json` | Parse JSON | `| json | level="ERROR"` |
| `| logfmt` | Parse logfmt | `| logfmt | status >= 500` |
| `| regexp` | Extract fields | `| regexp "status=(?P<status>\\d+)"` |

### Aggregation Queries

#### Count errors per service

```logql
sum by (service) (count_over_time({service=~".*"} |= "ERROR" [5m]))
```

#### Rate of requests per second

```logql
rate({service="kong"}[5m])
```

#### Top 10 error messages

```logql
topk(10, sum by (message) (count_over_time({level="ERROR"} [1h])))
```

---

## Using Grafana Explore

### Step 1: Open Explore

1. In Grafana, click **Explore** icon (compass) in left sidebar
2. Select **Loki** datasource from dropdown

### Step 2: Build Query

1. Click **Log browser** to see available labels
2. Select labels to filter (e.g., `service="auth"`)
3. Add search terms (e.g., `|= "ERROR"`)
4. Click **Run query**

### Step 3: Analyze Results

- **Log volume graph**: Shows log rate over time
- **Log results**: Individual log entries with context
- **Fields**: Extracted labels and fields from logs
- **Live tail**: Stream logs in real-time (click **Live** button)

### Creating Dashboards

#### Step 1: Create New Dashboard

1. Click **+** → **Dashboard**
2. Click **Add new panel**
3. Select **Loki** datasource

#### Step 2: Add Log Panel

Example: Error rate dashboard

**Query:**
```logql
sum by (service) (rate({service=~".*"} |= "ERROR" [5m]))
```

**Visualization**: Time series graph

**Panel title**: "Error Rate by Service"

#### Step 3: Add Table Panel

Example: Recent errors

**Query:**
```logql
{service=~".*"} |= "ERROR"
```

**Visualization**: Logs

**Panel title**: "Recent Errors"

---

## Log Retention

### Current Configuration

- **Retention period**: 30 days
- **Automatic cleanup**: Old logs deleted automatically
- **Compaction**: Runs every 10 minutes to reduce storage

### Storage Estimates

| Log Volume | Daily Storage | 30-Day Storage |
|------------|---------------|----------------|
| 100 MB/day | 100 MB | ~3 GB |
| 500 MB/day | 500 MB | ~15 GB |
| 1 GB/day | 1 GB | ~30 GB |

**Note**: Loki compresses logs significantly, actual storage may be 50-70% less.

### Adjusting Retention

Edit `monitoring/loki-config.yml`:

```yaml
limits_config:
  retention_period: 720h  # 30 days (change to desired hours)
```

Then restart Loki:

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml restart loki
```

### Monitoring Storage Usage

```bash
# Check Loki data volume size
docker volume inspect supabase_loki_data | jq '.[0].Mountpoint' | xargs sudo du -sh

# Check container disk usage
docker system df -v | grep loki
```

---

## Troubleshooting

### No Logs Appearing in Loki

**Check Promtail is running:**

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml ps promtail

# View Promtail logs
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml logs promtail
```

**Verify Promtail can reach Loki:**

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml exec promtail \
  wget -qO- http://loki:3100/ready
```

**Check Promtail is discovering containers:**

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml logs promtail | grep "adding target"
```

### Logs from Specific Service Missing

**Check container labels:**

```bash
docker inspect supabase-auth | jq '.[0].Config.Labels'
```

Should include: `com.docker.compose.project=supabase`

**Test Promtail configuration:**

```bash
# Validate Promtail config
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml \
  exec promtail promtail -config.file=/etc/promtail/promtail-config.yml -check-syntax
```

### High Memory Usage

Loki can consume memory if querying large time ranges.

**Reduce query limits** in `monitoring/loki-config.yml`:

```yaml
limits_config:
  max_query_length: 168h  # Reduce from 721h to 1 week
  max_query_parallelism: 16  # Reduce from 32
```

**Restart Loki:**

```bash
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml restart loki
```

### Slow Queries

**Use time range filters:**

```logql
{service="auth"}[5m]  # Query last 5 minutes only
```

**Use label filters before grep:**

```logql
# Good (efficient)
{service="auth"} |= "ERROR"

# Bad (inefficient)
{service=~".*"} |= "ERROR"
```

**Enable query caching** (already configured in provided config).

---

## Best Practices

### 1. Use Specific Label Selectors

❌ **Bad** (scans all services):
```logql
{service=~".*"} |= "ERROR"
```

✅ **Good** (scans only auth):
```logql
{service="auth"} |= "ERROR"
```

### 2. Limit Time Ranges

❌ **Bad** (queries 30 days):
```logql
{service="auth"}
```

✅ **Good** (queries last hour):
```logql
{service="auth"}[1h]
```

### 3. Use Structured Logging

Services using JSON logging enable powerful queries:

```logql
{service="auth"} | json | user_id="..." | level="ERROR"
```

### 4. Create Alerts from Logs

In Grafana, create alerts from log queries:

**Example**: Alert on high error rate

```logql
sum(rate({service=~".*"} |= "ERROR" [5m])) > 10
```

### 5. Correlate Logs with Metrics

Use the same labels in both Loki and Prometheus:

- `service`: Service name
- `container`: Container name
- `project`: Compose project

This enables jumping from metrics to logs in Grafana.

### 6. Regular Maintenance

```bash
# Weekly: Check storage usage
docker system df -v | grep loki

# Monthly: Verify retention is working
docker compose -f docker-compose.yml -f docker-compose.monitoring.yml \
  logs loki | grep "retention"
```

---

## Common Use Cases

### Debugging Auth Issues

```logql
{service="auth"} | json | level="ERROR" | user_id="<user-id>"
```

### Monitoring Database Slow Queries

```logql
{service="db"} |~ "duration: [0-9]{4,} ms"
```

### Tracking API Errors

```logql
{service="kong"} | logfmt | status >= 500
```

### Finding Service Crashes

```logql
{service=~".*"} |= "panic" or |= "fatal" or |= "crash"
```

### Audit Trail

```logql
{service="auth"} |= "signup" or |= "login" or |= "logout"
```

---

## Integration with Alerts

### Create Log-Based Alert

1. In Grafana, create alert from Explore:
   - Write LogQL query
   - Click **Alert** button
   - Configure threshold and notification

2. Example alert: High error rate

**Query:**
```logql
sum(rate({service=~".*"} |= "ERROR" [5m]))
```

**Condition:** `> 10` (more than 10 errors/second)

**Notification:** Email/Slack/PagerDuty

---

## Additional Resources

- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [LogQL Query Language](https://grafana.com/docs/loki/latest/logql/)
- [Promtail Configuration](https://grafana.com/docs/loki/latest/clients/promtail/configuration/)
- [Grafana Explore](https://grafana.com/docs/grafana/latest/explore/)

---

## Summary

You have now deployed a production-ready log aggregation stack. Key capabilities:

✅ **Centralized Logging**: All Supabase service logs in Loki
✅ **30-Day Retention**: Automated log retention and cleanup
✅ **Full-Text Search**: Query logs across all services with LogQL
✅ **Grafana Integration**: Unified metrics + logs interface
✅ **Low Overhead**: Minimal resource consumption
✅ **Alert Capability**: Create alerts from log patterns

**Next Steps:**

1. Create Grafana dashboards for common log queries
2. Set up alerts for critical errors
3. Document runbooks linking logs to resolution steps
4. Train team on LogQL querying
5. Integrate logs with incident response procedures
