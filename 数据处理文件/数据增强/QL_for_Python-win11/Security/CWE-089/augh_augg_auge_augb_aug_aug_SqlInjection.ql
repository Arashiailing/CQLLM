/**
 * @name SQL query constructed from user-controlled input
 * @description Detects SQL injection vulnerabilities where SQL statements are built
 *              using user-supplied data, enabling attackers to execute arbitrary SQL commands.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Core components for Python language analysis
import python

// Data flow analysis module specialized for SQL injection detection
import semmle.python.security.dataflow.SqlInjectionQuery

// Graphical representation utilities for path visualization
import SqlInjectionFlow::PathGraph

// Identify complete data flow paths from user input to SQL query construction
from 
  SqlInjectionFlow::PathNode userControlledInput,    // Node representing user-controlled input source
  SqlInjectionFlow::PathNode sqlInjectionPoint       // Node representing SQL injection vulnerability sink
where 
  // Verify existence of data flow from user input to SQL query
  SqlInjectionFlow::flowPath(userControlledInput, sqlInjectionPoint)
select 
  sqlInjectionPoint.getNode(),      // Pinpoint exact location of SQL injection vulnerability
  userControlledInput,              // Mark source of tainted data
  sqlInjectionPoint,                // Mark endpoint of data flow (vulnerability point)
  "This SQL query depends on $@.",   // Vulnerability description template
  userControlledInput.getNode(),    // Source node for message placeholder substitution
  "User-provided input"             // Category label for the contamination source