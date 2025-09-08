# Spark 3.5.6 Docker Setup with Iceberg, S3, and AWS Integration

This repository provides a complete Docker-based setup for Apache Spark 3.5.6 with support for:
- Apache Iceberg tables
- AWS Glue Data Catalog
- S3 storage integration
- AWS SDK bundle
- Spark UI and History Server

## Architecture

- **Spark Master**: Web UI on port 8080, Master service on port 7077
- **Spark Workers**: 2 workers with Web UIs on ports 8081 and 8082
- **History Server**: Web UI on port 18080 for completed applications
- **Thrift Server**: JDBC/ODBC interface on port 10000, Web UI on port 4041
- **Jupyter Notebook**: Optional interactive development environment on port 8888

## Prerequisites

- Docker and Docker Compose installed
- At least 8GB RAM available for Docker
- AWS credentials (optional, for S3/Glue integration)

## Quick Start

### 1. Clone and Navigate to the Directory

```bash
cd /Users/kynguyen/Workplace/local/spark
```

### 2. Build and Start the Cluster

```bash
# Start the complete Spark cluster
docker-compose up -d

# Or start core services (without Jupyter)
docker-compose up -d spark-master spark-worker-1 spark-worker-2 spark-history-server spark-thrift-server

# Or start minimal cluster (without Thrift Server and Jupyter)
docker-compose up -d spark-master spark-worker-1 spark-worker-2 spark-history-server
```

### 3. Verify the Setup

- **Spark Master UI**: http://localhost:8080
- **Spark Worker 1 UI**: http://localhost:8081  
- **Spark Worker 2 UI**: http://localhost:8082
- **Spark History Server**: http://localhost:18080
- **Spark Thrift Server UI**: http://localhost:4041
- **Jupyter Notebook**: http://localhost:8888 (if started)

## Usage Examples

### Running Spark Applications

#### Option 1: Submit Python Applications
```bash
# Copy your Python script to the scripts directory
# Then submit it to the cluster
docker-compose exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    --deploy-mode client \
    /opt/spark/scripts/test-iceberg.py
```

#### Option 2: Interactive Spark Shell
```bash
# Start Spark Shell
docker-compose exec spark-master spark-shell --master spark://spark-master:7077

# Or PySpark
docker-compose exec spark-master pyspark --master spark://spark-master:7077
```

#### Option 3: Use Jupyter Notebook
1. Start Jupyter service: `docker-compose up -d jupyter`
2. Open http://localhost:8888
3. Create a new notebook and start coding with Spark

#### Option 4: Connect via JDBC/ODBC (Thrift Server)
```bash
# Start Thrift Server
docker-compose up -d spark-thrift-server

# Test connection with Python
python3 scripts/test-thrift-server.py
```

**JDBC Connection Details:**
- **JDBC URL**: `jdbc:hive2://localhost:10000/default`
- **Host**: localhost
- **Port**: 10000
- **Username**: spark (or any username)
- **Password**: (leave empty)
- **Driver**: `org.apache.hive.jdbc.HiveDriver`

### Testing Iceberg Integration

Run the provided test script:
```bash
docker-compose exec spark-master python3 /opt/spark/scripts/test-iceberg.py
```

This script tests:
- Basic Spark operations
- Iceberg table creation
- Data reading/writing
- Integration verification

### Testing Thrift Server

Test JDBC connectivity with the provided script:
```bash
# Install required Python packages (outside container)
pip install pyhive pandas thrift sasl thrift_sasl

# Run the test script
python3 scripts/test-thrift-server.py
```

This script tests:
- JDBC connection to Thrift Server
- SQL query execution
- Database operations
- Pandas integration
- Iceberg catalog access (if configured)

## Configuration

### AWS Credentials Setup

To use S3 and Glue catalog features, configure AWS credentials:

#### Option 1: Environment Variables
Add to your `docker-compose.yml`:
```yaml
environment:
  - AWS_ACCESS_KEY_ID=your_access_key
  - AWS_SECRET_ACCESS_KEY=your_secret_key
  - AWS_DEFAULT_REGION=us-east-1
```

#### Option 2: AWS CLI Configuration
Mount your AWS credentials:
```yaml
volumes:
  - ~/.aws:/home/spark/.aws:ro
```

#### Option 3: Update spark-defaults.conf
Edit `conf/spark-defaults.conf`:
```properties
spark.hadoop.fs.s3a.access.key    your-access-key
spark.hadoop.fs.s3a.secret.key    your-secret-key
spark.hadoop.fs.s3a.endpoint      s3.amazonaws.com
```

### Customizing Spark Configuration

Edit `conf/spark-defaults.conf` to modify:
- Memory settings
- S3 configuration
- Iceberg catalog settings
- AWS Glue integration

## File Structure

```
.
├── Dockerfile                 # Spark image with all dependencies
├── docker-compose.yml         # Multi-service setup
├── entrypoint.sh             # Service startup script
├── conf/
│   ├── spark-defaults.conf   # Spark configuration
│   └── log4j2.properties     # Logging configuration
├── scripts/
│   └── test-iceberg.py       # Sample test application
├── data/                     # Data storage (mounted volume)
├── logs/                     # Spark logs
├── notebooks/                # Jupyter notebooks
└── work/                     # Spark work directory
```

## Monitoring and Debugging

### Web UIs

1. **Spark Master UI** (http://localhost:8080):
   - Cluster status and workers
   - Running and completed applications
   - Resource usage

2. **Spark Worker UIs** (http://localhost:8081, http://localhost:8082):
   - Worker status and resources
   - Running executors

3. **History Server** (http://localhost:18080):
   - Completed applications
   - Detailed execution plans
   - Performance metrics

4. **Thrift Server** (http://localhost:4041):
   - JDBC/ODBC connection status
   - Active SQL sessions
   - Running queries and execution plans

### Logs

View logs for troubleshooting:
```bash
# Master logs
docker-compose logs spark-master

# Worker logs  
docker-compose logs spark-worker-1

# History server logs
docker-compose logs spark-history-server

# Thrift server logs
docker-compose logs spark-thrift-server

# All services
docker-compose logs -f
```

### Container Shell Access

Access container shell for debugging:
```bash
docker-compose exec spark-master bash
docker-compose exec spark-worker-1 bash
```

## Advanced Usage

### Custom Applications

1. Place your application files in the `scripts/` directory
2. Submit using spark-submit:
```bash
docker-compose exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    --deploy-mode client \
    --conf spark.sql.catalog.my_catalog=org.apache.iceberg.spark.SparkCatalog \
    /opt/spark/scripts/your_app.py
```

### Iceberg with S3 Example

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Iceberg S3 Example") \
    .config("spark.sql.catalog.my_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.my_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.my_catalog.warehouse", "s3a://your-bucket/warehouse/") \
    .getOrCreate()

# Create Iceberg table in S3
df.write.format("iceberg") \
    .mode("overwrite") \
    .saveAsTable("my_catalog.my_database.my_table")
```

### Connecting BI Tools

The Thrift Server enables connections from various BI and analytics tools:

#### DBeaver
1. Create new connection → Apache Hive
2. Server Host: `localhost`, Port: `10000`
3. Database: `default`
4. Username: `spark`, Password: (empty)

#### Tableau
1. Connect → More... → Apache Spark SQL
2. Server: `localhost`, Port: `10000`
3. Username: `spark`

#### Power BI
1. Get Data → More → Spark
2. Server: `localhost:10000`
3. Protocol: Standard
4. Data Connectivity mode: DirectQuery

#### Python (PyHive)
```python
from pyhive import hive

conn = hive.Connection(host='localhost', port=10000, username='spark')
cursor = conn.cursor()
cursor.execute('SELECT * FROM your_table LIMIT 10')
results = cursor.fetchall()
```

#### Java (JDBC)
```java
String jdbcUrl = "jdbc:hive2://localhost:10000/default";
Connection conn = DriverManager.getConnection(jdbcUrl, "spark", "");
```

### Scaling Workers

Add more workers by modifying `docker-compose.yml`:
```yaml
spark-worker-3:
  build: .
  container_name: spark-worker-3
  # ... same configuration as other workers
  ports:
    - "8083:8081"
```

## Troubleshooting

### Common Issues

1. **Port conflicts**: Change host ports in docker-compose.yml
2. **Memory issues**: Adjust `SPARK_WORKER_MEMORY` and Docker memory limits
3. **AWS permissions**: Verify IAM roles and S3 bucket policies
4. **Networking**: Ensure Docker networks are properly configured

### Performance Tuning

Edit `conf/spark-defaults.conf`:
```properties
# Increase memory
spark.driver.memory              4g
spark.executor.memory            4g

# Optimize for your workload
spark.sql.adaptive.enabled       true
spark.sql.adaptive.coalescePartitions.enabled  true
spark.sql.adaptive.skewJoin.enabled  true
```

### Cleaning Up

```bash
# Stop all services
docker-compose down

# Remove volumes (caution: deletes data)
docker-compose down -v

# Clean up images
docker system prune -a
```

## Support

For issues with:
- **Spark**: Check Spark documentation and logs
- **Iceberg**: Verify catalog configuration and S3 permissions  
- **AWS**: Ensure proper credentials and IAM policies
- **Docker**: Check container resources and networking

## License

This setup is provided as-is for development and testing purposes.
