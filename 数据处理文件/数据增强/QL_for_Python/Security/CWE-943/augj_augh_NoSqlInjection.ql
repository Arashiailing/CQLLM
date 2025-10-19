/**
 * @name NoSQL Injection
 * @description Detects NoSQL injection vulnerabilities where user-controlled input
 *              is directly incorporated into NoSQL queries without sanitization.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 8.8
 * @id py/nosql-injection
 * @tags security
 *       external/cwe/cwe-943
 */

// Import Python analysis libraries
import python
// Import NoSQL injection data flow analysis module
import semmle.python.security.dataflow.NoSqlInjectionQuery
// Import path graph representation for data flow paths
import NoSqlInjectionFlow::PathGraph

// Define path source and sink nodes
from NoSqlInjectionFlow::PathNode sourceNode, NoSqlInjectionFlow::PathNode sinkNode
// Verify existence of data flow path between source and sink
where NoSqlInjectionFlow::flowPath(sourceNode, sinkNode)
// Output results: vulnerable node, path start, path end, warning message, source, input description
select sinkNode.getNode(), sourceNode, sinkNode, "This NoSQL query contains an unsanitized $@.", sourceNode,
  "user-provided value"