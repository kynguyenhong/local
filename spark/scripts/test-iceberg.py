#!/usr/bin/env python3
"""
Sample Spark application to test Iceberg integration
"""

from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType, TimestampType
from datetime import datetime

def create_spark_session():
    """Create Spark session with Iceberg configuration"""
    return SparkSession.builder \
        .appName("Iceberg Test Application") \
        .config("spark.sql.extensions", "org.apache.iceberg.spark.extensions.IcebergSparkSessionExtensions") \
        .config("spark.sql.catalog.spark_catalog", "org.apache.iceberg.spark.SparkSessionCatalog") \
        .config("spark.sql.catalog.spark_catalog.type", "hive") \
        .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
        .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
        .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
        .getOrCreate()

def test_basic_operations():
    """Test basic Spark operations"""
    spark = create_spark_session()
    
    print("=== Testing Basic Spark Operations ===")
    
    # Create sample data
    schema = StructType([
        StructField("id", IntegerType(), True),
        StructField("name", StringType(), True),
        StructField("category", StringType(), True),
        StructField("timestamp", TimestampType(), True)
    ])
    
    data = [
        (1, "Product A", "Electronics", datetime.now()),
        (2, "Product B", "Clothing", datetime.now()),
        (3, "Product C", "Electronics", datetime.now()),
        (4, "Product D", "Books", datetime.now()),
        (5, "Product E", "Clothing", datetime.now())
    ]
    
    df = spark.createDataFrame(data, schema)
    
    print("Sample DataFrame:")
    df.show()
    
    print("DataFrame Schema:")
    df.printSchema()
    
    print("Count by Category:")
    df.groupBy("category").count().show()
    
    return spark, df

def test_iceberg_table_creation(spark, df):
    """Test Iceberg table creation and operations"""
    print("\n=== Testing Iceberg Table Operations ===")
    
    try:
        # Create namespace/database
        spark.sql("CREATE NAMESPACE IF NOT EXISTS test_db")
        
        # Write DataFrame as Iceberg table
        df.write \
            .format("iceberg") \
            .mode("overwrite") \
            .option("path", "/opt/spark/data/iceberg/test_table") \
            .saveAsTable("test_db.sample_products")
        
        print("✓ Iceberg table created successfully!")
        
        # Read from Iceberg table
        iceberg_df = spark.table("test_db.sample_products")
        print("Data from Iceberg table:")
        iceberg_df.show()
        
        # Test time travel (if supported)
        print("✓ Iceberg integration working!")
        
    except Exception as e:
        print(f"❌ Iceberg table creation failed: {str(e)}")
        print("This might be expected if S3/Glue credentials are not configured")

def test_s3_connectivity(spark):
    """Test S3 connectivity (if credentials are available)"""
    print("\n=== Testing S3 Connectivity ===")
    
    try:
        # This will only work if AWS credentials are properly configured
        # spark.sql("SHOW DATABASES").show()  # This would show Glue databases if configured
        print("S3 connectivity test would require valid AWS credentials")
        print("Configure your AWS credentials and S3 bucket in spark-defaults.conf")
        
    except Exception as e:
        print(f"S3 connectivity test failed (expected without credentials): {str(e)}")

def main():
    """Main function"""
    print("Starting Spark Iceberg Integration Test")
    print("=" * 50)
    
    try:
        spark, df = test_basic_operations()
        test_iceberg_table_creation(spark, df)
        test_s3_connectivity(spark)
        
        print("\n" + "=" * 50)
        print("Test completed! Check the Spark UI at http://localhost:4040")
        print("Check the History Server at http://localhost:18080")
        
        spark.stop()
        
    except Exception as e:
        print(f"Test failed with error: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
