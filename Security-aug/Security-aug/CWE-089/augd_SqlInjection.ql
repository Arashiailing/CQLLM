/**
 * @name SQL query built from user-controlled sources
 * @description Detects SQL injection vulnerabilities where SQL queries are constructed
 *              using untrusted user input, enabling malicious SQL code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import Python language support for code analysis
import python

// Import specialized data flow tracking for SQL injection patterns
import semmle.python.security.dataflow.SqlInjectionQuery

// Import path graph visualization for data flow representation
import SqlInjectionFlow::PathGraph

// Identify vulnerable SQL query construction paths
from SqlInjectionFlow::PathNode userInputSource, SqlInjectionFlow::PathNode sqlExecutionSink
where 
  // Verify data flow exists from user input to SQL execution
  SqlInjectionFlow::flowPath(userInputSource, sqlExecutionSink)
select 
  sqlExecutionSink.getNode(), 
  userInputSource, 
  sqlExecutionSink, 
  "This SQL query depends on a $@.", 
  userInputSource.getNode(),
  "user-provided value"