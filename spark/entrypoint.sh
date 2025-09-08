#!/bin/bash

set -e

# Parse arguments
SPARK_MODE="$1"
MASTER_ENDPOINT="${2:-localhost:7077}"
shift 2 2>/dev/null || shift 1 2>/dev/null || true

# Extract host and port from master endpoint
MASTER_HOST=$(echo $MASTER_ENDPOINT | cut -d':' -f1)
MASTER_PORT=$(echo $MASTER_ENDPOINT | cut -d':' -f2)

# Set SPARK_MASTER_URL if not already set
if [ -z "$SPARK_MASTER_URL" ]; then
    export SPARK_MASTER_URL="spark://$MASTER_ENDPOINT"
fi

echo "Using Spark Master: $SPARK_MASTER_URL"

# Wait for dependencies to be available
wait_for_port() {
    local host=$1
    local port=$2
    local timeout=${3:-60}
    
    echo "Waiting for $host:$port to become available..."
    for i in $(seq 1 $timeout); do
        if command -v nc >/dev/null && nc -z $host $port > /dev/null 2>&1; then
            echo "$host:$port is available"
            return 0
        elif command -v telnet >/dev/null && echo "quit" | telnet $host $port > /dev/null 2>&1; then
            echo "$host:$port is available"
            return 0
        elif timeout 2 bash -c "exec 3<>/dev/tcp/$host/$port && exec 3<&- && exec 3>&-" > /dev/null 2>&1; then
            echo "$host:$port is available"
            return 0
        fi
        sleep 1
    done
    echo "Timeout waiting for $host:$port"
    return 1
}

# Start services based on command argument
case "$SPARK_MODE" in
    master)
        echo "Starting Spark Master..."
        $SPARK_HOME/sbin/start-master.sh
        exec tail -f $SPARK_HOME/logs/spark-*spark-master.out
        ;;
    worker)
        echo "Starting Spark Worker..."
        wait_for_port $MASTER_HOST $MASTER_PORT
        $SPARK_HOME/sbin/start-worker.sh $SPARK_MASTER_URL
        exec tail -f $SPARK_HOME/logs/spark-*.out
        ;;
    history-server)
        echo "Starting Spark History Server..."
        # Ensure the events directory exists with proper permissions
        mkdir -p /tmp/spark-events
        chown -R spark:spark /tmp/spark-events
        chmod -R 755 /tmp/spark-events
        $SPARK_HOME/sbin/start-history-server.sh
        exec tail -f $SPARK_HOME/logs/spark-*spark-history-server.out
        ;;
    thrift-server)
        echo "Starting Spark Thrift Server..."
        wait_for_port $MASTER_HOST $MASTER_PORT
        # Ensure the events directory exists with proper permissions
        # Try to create directory - if it fails due to permissions, continue anyway
        mkdir -p /tmp/spark-events 2>/dev/null || true
        chmod 777 /tmp/spark-events 2>/dev/null || true
        
        # Build thrift server arguments
        THRIFT_ARGS="--master $SPARK_MASTER_URL"
        
        # Add custom options from THRIFT_OPTION environment variable
        if [ -n "$THRIFT_OPTION" ]; then
            echo "Adding custom thrift options: $THRIFT_OPTION"
            THRIFT_ARGS="$THRIFT_ARGS $THRIFT_OPTION"
        fi
        
        echo "Starting Thrift Server with arguments: $THRIFT_ARGS"
        $SPARK_HOME/sbin/start-thriftserver.sh $THRIFT_ARGS
        exec tail -f $SPARK_HOME/logs/spark-*spark-thrift-server.out
        ;;
    jupyter)
        echo "Starting Jupyter Notebook with PySpark..."
        # Install additional Python packages
        pip3 install --user jupyter pyspark==3.5.6 findspark
        
        # Create notebooks directory if it doesn't exist
        mkdir -p /home/spark/notebooks
        
        # Set up PySpark environment
        export PYSPARK_DRIVER_PYTHON=jupyter
        export PYSPARK_DRIVER_PYTHON_OPTS="notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --notebook-dir=/home/spark/notebooks"
        
        # Start Jupyter
        exec jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root --notebook-dir=/home/spark/notebooks
        ;;
    shell)
        echo "Starting Spark Shell..."
        wait_for_port $MASTER_HOST $MASTER_PORT
        exec $SPARK_HOME/bin/spark-shell --master $SPARK_MASTER_URL
        ;;
    submit)
        echo "Submitting Spark Application..."
        wait_for_port $MASTER_HOST $MASTER_PORT
        exec $SPARK_HOME/bin/spark-submit --master $SPARK_MASTER_URL "$@"
        ;;
    bash)
        echo "Starting bash shell..."
        exec /bin/bash
        ;;
    *)
        echo "Usage: $0 {master|worker|history-server|thrift-server|jupyter|shell|submit|bash} [master_endpoint]"
        echo "  master_endpoint: Format 'host:port' (default: localhost:7077)"
        echo "For submit mode, pass additional arguments after master_endpoint"
        echo "For thrift-server mode, use THRIFT_OPTION environment variable for custom arguments"
        echo ""
        echo "Environment Variables:"
        echo "  THRIFT_OPTION: Additional arguments to pass to thrift server (space-separated)"
        echo ""
        echo "Examples:"
        echo "  $0 master"
        echo "  $0 worker localhost:7077"
        echo "  $0 worker spark-master:7077"
        echo "  $0 thrift-server"
        echo "  THRIFT_OPTION='--conf spark.sql.warehouse.dir=/tmp/warehouse --hiveconf hive.server2.thrift.port=10001' $0 thrift-server"
        echo "  $0 submit localhost:7077 /path/to/app.py"
        exit 1
        ;;
esac
