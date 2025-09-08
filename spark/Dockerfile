# Use official Apache Spark image - try 3.5.6 first, fallback if needed
FROM apache/spark:3.5.5-scala2.12-java17-python3-r-ubuntu

# Download Iceberg and AWS JARs for Spark 3.5
RUN wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.8.1/iceberg-spark-runtime-3.5_2.12-1.8.1.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws/1.8.1/iceberg-aws-1.8.1.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.25.11/bundle-2.25.11.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/software/amazon/awssdk/url-connection-client/2.25.11/url-connection-client-2.25.11.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.651/aws-java-sdk-bundle-1.12.651.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/software/amazon/s3tables/s3-tables-catalog-for-iceberg-runtime/0.1.8/s3-tables-catalog-for-iceberg-runtime-0.1.8.jar && \
    wget -P ${SPARK_HOME}/jars/ https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws-bundle/1.9.2/iceberg-aws-bundle-1.9.2.jar

# Create entrypoint script


USER root

COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Create spark-events directory with proper permissions
RUN mkdir -p /tmp/spark-events && \
    chown -R spark:spark /tmp/spark-events && \
    chmod -R 777 /tmp/spark-events

# Expose ports
EXPOSE 8080 8081 7077 4040 18080

WORKDIR ${SPARK_HOME}

USER spark

ENTRYPOINT ["/opt/entrypoint.sh"]
