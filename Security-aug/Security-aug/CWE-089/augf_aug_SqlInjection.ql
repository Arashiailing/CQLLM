/**
 * @name SQL query constructed from untrusted input sources
 * @description Building SQL queries with user-controllable input allows attackers
 *              to execute malicious SQL statements, resulting in SQL injection flaws.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import core Python analysis framework for AST processing
import python

// Import SQL injection tracking module for tainted data flow analysis
import semmle.python.security.dataflow.SqlInjectionQuery

// Import path visualization utilities for data flow trajectory rendering
import SqlInjectionFlow::PathGraph

// Trace data flow paths from untrusted sources to vulnerable SQL sinks
from SqlInjectionFlow::PathNode taintedSource, SqlInjectionFlow::PathNode sqlSink
where SqlInjectionFlow::flowPath(taintedSource, sqlSink)  // Verify data flow connection
select 
  sqlSink.getNode(),       // Vulnerable SQL construction location
  taintedSource,           // Origin of untrusted data
  sqlSink,                 // Termination point of data flow
  "This SQL query incorporates a $@.",  // Vulnerability description template
  taintedSource.getNode(), // Source node for parameter substitution
  "user-controlled input"  // Label identifying untrusted data origin