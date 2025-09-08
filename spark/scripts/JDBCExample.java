/*
 * Example JDBC connection to Spark Thrift Server
 * Compile with: javac -cp "hive-jdbc-*.jar" JDBCExample.java
 * Run with: java -cp ".:hive-jdbc-*.jar" JDBCExample
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class JDBCExample {
    
    private static final String JDBC_URL = "jdbc:hive2://localhost:10000/default";
    private static final String USERNAME = "spark";
    private static final String PASSWORD = "";
    
    public static void main(String[] args) {
        System.out.println("Spark Thrift Server JDBC Connection Example");
        System.out.println("==========================================");
        
        Connection connection = null;
        Statement statement = null;
        
        try {
            // Load the Hive JDBC driver
            Class.forName("org.apache.hive.jdbc.HiveDriver");
            
            // Establish connection
            System.out.println("Connecting to Spark Thrift Server...");
            connection = DriverManager.getConnection(JDBC_URL, USERNAME, PASSWORD);
            System.out.println("✓ Connected successfully!");
            
            // Create statement
            statement = connection.createStatement();
            
            // Test 1: Show databases
            System.out.println("\n1. Showing databases:");
            ResultSet databases = statement.executeQuery("SHOW DATABASES");
            while (databases.next()) {
                System.out.println("   - " + databases.getString(1));
            }
            databases.close();
            
            // Test 2: Create and query test data
            System.out.println("\n2. Creating test data:");
            statement.execute("CREATE OR REPLACE TEMPORARY VIEW jdbc_test AS " +
                "SELECT * FROM VALUES " +
                "(1, 'John', 'Engineering', 75000), " +
                "(2, 'Jane', 'Marketing', 65000), " +
                "(3, 'Bob', 'Engineering', 80000), " +
                "(4, 'Alice', 'Sales', 70000) " +
                "AS t(id, name, department, salary)");
            System.out.println("   ✓ Test view created");
            
            // Test 3: Query data
            System.out.println("\n3. Querying test data:");
            ResultSet employees = statement.executeQuery(
                "SELECT * FROM jdbc_test ORDER BY id");
            System.out.println("   ID | Name  | Department  | Salary");
            System.out.println("   ---|-------|-------------|-------");
            while (employees.next()) {
                System.out.printf("   %-2d | %-5s | %-11s | $%d%n",
                    employees.getInt("id"),
                    employees.getString("name"),
                    employees.getString("department"),
                    employees.getInt("salary"));
            }
            employees.close();
            
            // Test 4: Aggregation query
            System.out.println("\n4. Department statistics:");
            ResultSet stats = statement.executeQuery(
                "SELECT department, " +
                "COUNT(*) as emp_count, " +
                "ROUND(AVG(salary), 0) as avg_salary, " +
                "SUM(salary) as total_salary " +
                "FROM jdbc_test " +
                "GROUP BY department " +
                "ORDER BY department");
            
            System.out.println("   Department  | Count | Avg Salary | Total Salary");
            System.out.println("   ------------|-------|------------|-------------");
            while (stats.next()) {
                System.out.printf("   %-11s | %-5d | $%-9.0f | $%d%n",
                    stats.getString("department"),
                    stats.getInt("emp_count"),
                    stats.getDouble("avg_salary"),
                    stats.getLong("total_salary"));
            }
            stats.close();
            
            System.out.println("\n✓ All JDBC operations completed successfully!");
            
        } catch (ClassNotFoundException e) {
            System.err.println("❌ Hive JDBC driver not found!");
            System.err.println("Make sure hive-jdbc JAR is in classpath");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("❌ SQL Exception occurred:");
            e.printStackTrace();
        } finally {
            // Clean up
            try {
                if (statement != null) statement.close();
                if (connection != null) connection.close();
                System.out.println("\nConnection closed.");
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        System.out.println("\n==========================================");
        System.out.println("Connection Details:");
        System.out.println("- JDBC URL: " + JDBC_URL);
        System.out.println("- Username: " + USERNAME);
        System.out.println("- Driver: org.apache.hive.jdbc.HiveDriver");
        System.out.println("- Thrift Server Web UI: http://localhost:4041");
    }
}
