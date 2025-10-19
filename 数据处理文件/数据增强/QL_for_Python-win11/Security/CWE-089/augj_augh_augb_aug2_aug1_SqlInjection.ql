/**
 * @name SQL query built from user-controlled sources
 * @description Constructing SQL queries using user-controlled input allows attackers to inject
 *              malicious SQL code through crafted input, leading to potential data breaches.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Core analysis modules for Python security checks
import python
import semmle.python.security.dataflow.SqlInjectionQuery
import SqlInjectionFlow::PathGraph

// Define data flow path from user input source to SQL execution sink
from 
  SqlInjectionFlow::PathNode sourceNode,  // Origin point of user-controlled data
  SqlInjectionFlow::PathNode sinkNode     // SQL query construction/execution point
where 
  SqlInjectionFlow::flowPath(sourceNode, sinkNode)  // Verify data flow connection
select 
  sinkNode.getNode(),  // Vulnerability location (SQL execution)
  sourceNode,          // Data flow origin
  sinkNode,            // Data flow destination
  "This SQL query depends on a $@.",  // Vulnerability description template
  sourceNode.getNode(),  // Template parameter: user input location
  "user-provided value"  // Source type classification