/**
 * @name SQL query constructed from external inputs
 * @description Constructing SQL queries using external input sources allows attackers to inject
 *              malicious SQL code through user-controlled data.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import Python libraries for parsing and analyzing Python code
import python

// Import data flow analysis modules for SQL injection detection
import semmle.python.security.dataflow.SqlInjectionQuery

// Import path graph representation for data flow visualization
import SqlInjectionFlow::PathGraph

// Identify data flow paths from input sources to SQL construction points
from SqlInjectionFlow::PathNode originNode, SqlInjectionFlow::PathNode destinationNode
where SqlInjectionFlow::flowPath(originNode, destinationNode) // Ensure data flow path exists
select destinationNode.getNode(), originNode, destinationNode, 
       "This SQL query is built using a $@.", originNode.getNode(),
       "user-controlled input"