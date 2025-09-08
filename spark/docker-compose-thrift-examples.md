# Docker Compose Examples for Spark Thrift Server with THRIFT_OPTION

# This file contains various examples of how to configure the Spark Thrift Server
# using the THRIFT_OPTION environment variable

## Example 1: Basic Configuration
# environment:
#   - THRIFT_OPTION=--hiveconf hive.server2.thrift.port=10000 --hiveconf hive.server2.thrift.bind.host=0.0.0.0

## Example 2: Custom Warehouse Directory
# environment:
#   - THRIFT_OPTION=--conf spark.sql.warehouse.dir=/custom/warehouse/path

## Example 3: Performance Tuning
# environment:
#   - THRIFT_OPTION=--conf spark.serializer=org.apache.spark.serializer.KryoSerializer --conf spark.sql.adaptive.enabled=true --conf spark.sql.adaptive.coalescePartitions.enabled=true

## Example 4: Authentication with Kerberos
# environment:
#   - THRIFT_OPTION=--hiveconf hive.server2.authentication=KERBEROS --hiveconf hive.server2.authentication.kerberos.principal=spark/_HOST@REALM --hiveconf hive.server2.authentication.kerberos.keytab=/path/to/keytab

## Example 5: Custom Configuration File
# environment:
#   - THRIFT_OPTION=--properties-file /opt/spark/conf/custom-thrift.conf

## Example 6: Multiple Configurations Combined
# environment:
#   - THRIFT_OPTION=--hiveconf hive.server2.thrift.port=10001 --hiveconf hive.server2.thrift.bind.host=0.0.0.0 --conf spark.sql.warehouse.dir=/tmp/warehouse --conf spark.eventLog.enabled=true --conf spark.eventLog.dir=/tmp/spark-events --conf spark.ui.port=4040

## Example 7: HTTP Transport Mode
# environment:
#   - THRIFT_OPTION=--hiveconf hive.server2.transport.mode=http --hiveconf hive.server2.thrift.http.port=10001 --hiveconf hive.server2.thrift.http.path=cliservice

## Example 8: Session Configuration
# environment:
#   - THRIFT_OPTION=--hiveconf hive.server2.idle.session.timeout=3600000 --hiveconf hive.server2.idle.operation.timeout=300000 --hiveconf hive.server2.session.check.interval=60000

## Example 9: Thread Pool Configuration
# environment:
#   - THRIFT_OPTION=--hiveconf hive.server2.thrift.min.worker.threads=5 --hiveconf hive.server2.thrift.max.worker.threads=500

## Example 10: Iceberg Configuration
# environment:
#   - THRIFT_OPTION=--conf spark.sql.extensions=org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions --conf spark.sql.catalog.spark_catalog=org.apache.iceberg.spark.SparkSessionCatalog --conf spark.sql.catalog.spark_catalog.type=hive

# Note: You can combine multiple options in a single THRIFT_OPTION variable
# Just separate each argument with a space
