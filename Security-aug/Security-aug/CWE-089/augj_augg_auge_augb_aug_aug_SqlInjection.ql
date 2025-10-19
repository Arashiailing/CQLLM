/**
 * @name SQL query constructed from user-controlled input
 * @description Detects potential SQL injection vulnerabilities where SQL statements
 *              are built using untrusted user input, enabling attackers to execute
 *              arbitrary SQL commands.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 8.8
 * @precision high
 * @id py/sql-injection
 * @tags security
 *       external/cwe/cwe-089
 */

// Import core components for Python language analysis
import python

// Import data flow analysis module specifically for SQL injection vulnerability detection
import semmle.python.security.dataflow.SqlInjectionQuery

// Import graphical representation tools for path visualization in results
import SqlInjectionFlow::PathGraph

// Define data flow tracking: identify complete paths from user input to SQL query construction
from 
  SqlInjectionFlow::PathNode userInputSource,      // Represents a node where user-controlled input originates
  SqlInjectionFlow::PathNode sqlInjectionSink      // Represents a vulnerable sink point where SQL injection could occur
where 
  // Verify existence of data flow from user input to SQL query construction
  SqlInjectionFlow::flowPath(userInputSource, sqlInjectionSink)
select 
  sqlInjectionSink.getNode(),      // Pinpoint the exact location of the SQL injection vulnerability
  userInputSource,                 // Reference to the source node of the tainted data
  sqlInjectionSink,                // Reference to the sink node (vulnerability point)
  "此SQL查询依赖于$@。",           // Message template describing the vulnerability
  userInputSource.getNode(),       // Source node for message placeholder replacement
  "用户提供的输入"                // Category label for the contamination source