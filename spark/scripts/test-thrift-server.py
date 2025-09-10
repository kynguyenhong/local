#!/usr/bin/env python3
"""
Sample script to test Spark Thrift Server JDBC connectivity
"""

import sys
import time
from pyhive import hive
from pyhive.exc import DatabaseError
import pandas as pd
from tabulate import tabulate

# Connect Spark Thrift Server 

spark_thrift_host = 'localhost'
spark_thrift_port = 10001




# S3 table catalog configuration for Spark Thrift Server session
configuration = {
    "spark.driver.memory" : "4g"
}

conn = hive.Connection(host=spark_thrift_host, port=spark_thrift_port, configuration=configuration)
cursor = conn.cursor()


def execute_query(query):
    try:
        cursor.execute(query)
        results = cursor.fetchall()
        df = pd.DataFrame(results)
        print(tabulate(df, headers='keys', tablefmt='psql', showindex=False))
    except DatabaseError as e:
        print(f"\033[91mDatabase error:\033[0m {e}")
    except Exception as e:
        print(f"\033[91mError:\033[0m {e}")


# execute_query get all configuration
# execute_query("GET spark.sql.catalog.s3tablesbucket.*")

# execute_query("SHOW DATABASES in s3tablesbucket")
execute_query("show tables in olap_aggregated like '*'")


cursor.close()
conn.close()
