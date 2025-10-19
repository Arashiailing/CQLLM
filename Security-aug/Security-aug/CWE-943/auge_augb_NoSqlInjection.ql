/**
 * @name NoSQL Injection
 * @description Identifies NoSQL injection vulnerabilities where untrusted user input 
 *              is directly incorporated into NoSQL queries without proper validation.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 8.8
 * @id py/nosql-injection
 * @tags security
 *       external/cwe/cwe-943
 */

// Import Python analysis framework
import python
// Import NoSQL injection vulnerability detection module
import semmle.python.security.dataflow.NoSqlInjectionQuery
// Import path graph representation for data flow analysis
import NoSqlInjectionFlow::PathGraph

// Define source and sink nodes for vulnerability detection
from NoSqlInjectionFlow::PathNode sourceNode, NoSqlInjectionFlow::PathNode sinkNode
// Verify existence of data flow path from source to sink
where NoSqlInjectionFlow::flowPath(sourceNode, sinkNode)
// Output results with vulnerability details
select sinkNode.getNode(), sourceNode, sinkNode, "This NoSQL query contains an unsanitized $@.", sourceNode,
  "user-provided value"