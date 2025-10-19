/**
 * @name SQL query constructed from user-controlled inputs
 * @description Constructing SQL queries using user-controlled inputs can lead to SQL injection
 *              attacks, allowing malicious users to manipulate SQL statements.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Python source code analysis library
import python

// Core module for SQL injection data flow analysis
import semmle.python.security.dataflow.SqlInjectionQuery

// Module for visualizing SQL injection paths
import SqlInjectionFlow::PathGraph

// Identify data flow paths from user input sources to SQL query sinks
from SqlInjectionFlow::PathNode inputOrigin, SqlInjectionFlow::PathNode sqlSink
where SqlInjectionFlow::flowPath(inputOrigin, sqlSink)
select 
  sqlSink.getNode(),  // The SQL query location
  inputOrigin,        // Source of the data flow path
  sqlSink,            // Destination of the data flow path
  "This SQL query depends on a $@.",  // Security issue description template
  inputOrigin.getNode(),  // User input source node for issue description
  "user-provided value"   // Description of the user input source