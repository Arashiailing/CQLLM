/**
 * @name SQL query constructed from user-controlled input sources
 * @description Constructing SQL queries using user-controlled input sources can lead to SQL injection
 *              vulnerabilities, allowing attackers to execute arbitrary SQL commands.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import Python language analysis support
import python

// Import SQL injection vulnerability data flow analysis module
import semmle.python.security.dataflow.SqlInjectionQuery

// Import SQL injection path visualization utilities
import SqlInjectionFlow::PathGraph

// Define query to identify data flow from user-controlled sources to SQL query construction points
from 
  SqlInjectionFlow::PathNode userInputSource, 
  SqlInjectionFlow::PathNode sqlQuerySink
where 
  SqlInjectionFlow::flowPath(userInputSource, sqlQuerySink)
select 
  // Report location: SQL query execution point
  sqlQuerySink.getNode(), 
  // Data flow path source node (user input)
  userInputSource, 
  // Data flow path destination node (SQL query construction)
  sqlQuerySink, 
  // Vulnerability description template
  "This SQL query depends on a $@.", 
  // Template parameter: user input source node
  userInputSource.getNode(), 
  // Description of user input source
  "user-provided value"