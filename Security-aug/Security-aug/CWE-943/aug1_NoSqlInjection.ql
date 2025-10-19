/**
 * @name NoSQL Injection
 * @description Building a NoSQL query from user-controlled sources is vulnerable to insertion of
 *              malicious NoSQL code by the user.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 8.8
 * @id py/nosql-injection
 * @tags security
 *       external/cwe/cwe-943
 */

// Import Python libraries for code analysis
import python
// Import NoSQL injection detection module
import semmle.python.security.dataflow.NoSqlInjectionQuery
// Import path graph representation for data flow tracking
import NoSqlInjectionFlow::PathGraph

// Define path nodes representing data flow sources and sinks
from NoSqlInjectionFlow::PathNode origin, NoSqlInjectionFlow::PathNode destination
// Ensure data flows from user-controlled source to NoSQL query sink
where NoSqlInjectionFlow::flowPath(origin, destination)
// Report results with vulnerability details and flow path
select destination.getNode(), 
       origin, 
       destination, 
       "This NoSQL query contains an unsanitized $@.", 
       origin, 
       "user-provided value"