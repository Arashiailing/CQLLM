/**
 * @name SQL query built from user-controlled sources
 * @description Building a SQL query from user-controlled sources is vulnerable to insertion of
 *              malicious SQL code by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Core Python analysis libraries
import python

// SQL injection data flow analysis components
import semmle.python.security.dataflow.SqlInjectionQuery

// Path visualization for SQL injection flows
import SqlInjectionFlow::PathGraph

// Identify data flow paths from user input sources to SQL query construction
from 
  // Origin point of user-controlled data
  SqlInjectionFlow::PathNode userInputSource,
  // Destination point where SQL queries are constructed
  SqlInjectionFlow::PathNode sqlQuerySink
where 
  // Verify complete data flow path exists from source to sink
  SqlInjectionFlow::flowPath(userInputSource, sqlQuerySink)
select 
  // SQL query construction location
  sqlQuerySink.getNode(),
  // Path origin (user input source)
  userInputSource,
  // Path destination (SQL query sink)
  sqlQuerySink,
  // Security vulnerability description
  "This SQL query depends on a $@.",
  // Source node reference for message
  userInputSource.getNode(),
  // Source description text
  "user-provided value"