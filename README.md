# Local Spark Development Environment

A complete Docker-based Apache Spark 3.5.6 setup for local development with Iceberg, S3, and AWS integration.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 8GB RAM available for Docker
- AWS credentials configured (optional, for S3/Glue integration)

### 1. Start Spark Cluster
```bash
cd spark
docker-compose up -d
```

### 2. Verify Installation
Open these URLs in your browser:
- **Spark Master UI**: http://localhost:8080
- **Spark Worker 1**: http://localhost:8081  
- **Spark Worker 2**: http://localhost:8082
- **History Server**: http://localhost:18080
- **Thrift Server**: http://localhost:4040

### 3. Run Your First Spark Job
```bash
# Interactive Spark Shell
docker-compose exec spark-master spark-shell --master spark://spark-master:7077

# Or PySpark
docker-compose exec spark-master pyspark --master spark://spark-master:7077

# Or submit a Python script
docker-compose exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    /opt/spark/scripts/test-iceberg.py
```

## 📁 Project Structure

```
.
├── README.md                 # This file
├── .gitignore               # Git ignore rules
└── spark/                   # Spark setup directory
    ├── README.md            # Detailed Spark documentation
    ├── Dockerfile           # Spark image with all dependencies
    ├── docker-compose.yml   # Multi-service setup
    ├── entrypoint.sh        # Service startup script
    ├── conf/                # Spark configuration files
    │   ├── spark-defaults.conf
    │   ├── thrift-server.conf
    │   └── log4j2.properties
    ├── scripts/             # Sample scripts and tests
    │   ├── test-iceberg.py
    │   ├── test-thrift-server.py
    │   └── JDBCExample.java
    ├── data/                # Local data storage (ignored in git)
    ├── logs/                # Spark logs (ignored in git)
    ├── notebooks/           # Jupyter notebooks
    └── work/                # Spark work directory (ignored in git)
```

## 🔧 Common Commands

### Start/Stop Services
```bash
# Start all services
cd spark && docker-compose up -d

# Start minimal cluster (without Thrift Server)
cd spark && docker-compose up -d spark-master spark-worker-1 spark-worker-2 spark-history-server

# Stop all services
cd spark && docker-compose down

# View logs
cd spark && docker-compose logs -f
```

### Running Spark Applications

#### Submit Python Script
```bash
cd spark
docker-compose exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    --deploy-mode client \
    /opt/spark/scripts/your-script.py
```

#### Interactive Development
```bash
cd spark
# Scala Shell
docker-compose exec spark-master spark-shell --master spark://spark-master:7077

# Python Shell  
docker-compose exec spark-master pyspark --master spark://spark-master:7077

# Access container for debugging
docker-compose exec spark-master bash
```

#### JDBC/ODBC Connections (Thrift Server)
The Thrift Server allows connecting BI tools and databases:
- **JDBC URL**: `jdbc:hive2://localhost:10001/default`
- **Host**: localhost
- **Port**: 10001
- **Username**: spark
- **Password**: (empty)

Test connection:
```bash
cd spark
python3 scripts/test-thrift-server.py
```

## 🎯 Development Workflow

### 1. Add Your Scripts
Place your Spark applications in `spark/scripts/`:
```bash
# Copy your Python/Scala files
cp your-spark-app.py spark/scripts/
```

### 2. Test Locally
```bash
cd spark
docker-compose exec spark-master spark-submit \
    --master spark://spark-master:7077 \
    /opt/spark/scripts/your-spark-app.py
```

### 3. Monitor Execution
- Check Spark UI: http://localhost:8080
- View application details: http://localhost:4040
- Check logs: `docker-compose logs spark-master`

## 🗃️ Data Management

### Local Development Data
- Place test data files in `spark/data/`
- Access from Spark: `/opt/spark/data/your-file.csv`
- Data persists between container restarts

### Iceberg Tables
The setup includes Apache Iceberg for modern table format:
```python
# Example: Create Iceberg table
df.write.format("iceberg") \
    .mode("overwrite") \
    .saveAsTable("local.db.my_table")
```

### S3 Integration
Configure AWS credentials for S3 access:
```bash
# Using AWS CLI (recommended)
aws configure

# Or set environment variables
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export AWS_DEFAULT_REGION=ap-southeast-1
```

## 🔍 Monitoring & Debugging

### Web UIs
| Service | URL | Description |
|---------|-----|-------------|
| Spark Master | http://localhost:8080 | Cluster overview, workers, applications |
| Worker 1 | http://localhost:8081 | Worker status and executors |
| Worker 2 | http://localhost:8082 | Worker status and executors |
| History Server | http://localhost:18080 | Completed applications |
| Thrift Server | http://localhost:4040 | JDBC/SQL interface |

### Logs and Troubleshooting
```bash
cd spark

# View all logs
docker-compose logs

# View specific service logs
docker-compose logs spark-master
docker-compose logs spark-worker-1

# Follow logs in real-time
docker-compose logs -f

# Check container status
docker-compose ps
```

## ⚙️ Configuration

### Performance Tuning
Edit `spark/conf/spark-defaults.conf`:
```properties
# Increase memory allocation
spark.driver.memory              4g
spark.executor.memory            4g
spark.executor.cores             2

# Enable adaptive query execution
spark.sql.adaptive.enabled       true
spark.sql.adaptive.coalescePartitions.enabled  true
```

### AWS Configuration
For S3 and Glue integration, see the detailed configuration in `spark/README.md`.

## 🆘 Troubleshooting

### Common Issues

1. **Port conflicts**: Change ports in `docker-compose.yml`
2. **Memory issues**: Increase Docker memory limits
3. **Permission errors**: Check file permissions in mounted volumes
4. **AWS access**: Verify credentials and IAM permissions

### Getting Help

1. Check the detailed documentation: `spark/README.md`
2. View container logs: `docker-compose logs [service-name]`
3. Access container shell: `docker-compose exec spark-master bash`
4. Check Spark UI for application details

## 🧹 Cleanup

```bash
# Stop services
cd spark && docker-compose down

# Remove all data (careful!)
cd spark && docker-compose down -v

# Clean Docker images
docker system prune -a
```

---

📖 **For detailed configuration and advanced usage**, see [spark/README.md](spark/README.md)

🔗 **Useful Links**:
- [Apache Spark Documentation](https://spark.apache.org/docs/latest/)
- [Apache Iceberg Documentation](https://iceberg.apache.org/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
