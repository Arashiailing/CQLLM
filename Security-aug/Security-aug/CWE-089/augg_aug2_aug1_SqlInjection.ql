/**
 * @name SQL query constructed from user-controlled input
 * @description Constructing SQL queries using user-controlled input without proper sanitization
 *              allows attackers to inject malicious SQL code, potentially leading to
 *              unauthorized data access or database manipulation.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import Python analysis framework
import python

// Import SQL injection taint tracking analysis module
import semmle.python.security.dataflow.SqlInjectionQuery

// Import SQL injection path visualization components
import SqlInjectionFlow::PathGraph

// Query definition: Identify data flow paths from user input sources to SQL query sinks
from 
  SqlInjectionFlow::PathNode inputSource,  // Source node representing user input
  SqlInjectionFlow::PathNode sqlSink       // Sink node representing SQL query construction
where 
  SqlInjectionFlow::flowPath(inputSource, sqlSink)  // Verify complete data flow path exists
select 
  sqlSink.getNode(),    // Target node where SQL query is constructed
  inputSource,          // Starting point of data flow path
  sqlSink,              // Ending point of data flow path
  "This SQL query depends on a $@.",  // Security issue description template
  inputSource.getNode(), // Source node reference for issue description
  "user-provided value"  // Description text for the user input source