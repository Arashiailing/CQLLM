/**
 * @name SQL query constructed from user-controlled input
 * @description Constructing SQL queries using user-controlled input can lead to SQL injection
 *              attacks, where malicious SQL code is injected by the user.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import Python library for parsing and analyzing Python code
import python

// Import data flow analysis module specifically for SQL injection detection
import semmle.python.security.dataflow.SqlInjectionQuery

// Import path graph module to visualize and represent data flow paths
import SqlInjectionFlow::PathGraph

// Define the main query to identify data flow paths from user input to SQL queries
from 
  // Define origin node representing user-controlled input
  SqlInjectionFlow::PathNode origin, 
  // Define target node representing SQL query construction
  SqlInjectionFlow::PathNode target
where 
  // Condition: there exists a data flow path from origin to target
  SqlInjectionFlow::flowPath(origin, target)
select 
  // Select the target node where SQL injection occurs
  target.getNode(), 
  // Include the origin node in the result
  origin, 
  // Include the target node in the result
  target, 
  // Description message with reference to the origin
  "This SQL query depends on a $@.", 
  // Reference to the origin node for the description
  origin.getNode(),
  // Label for the origin node
  "user-provided value"