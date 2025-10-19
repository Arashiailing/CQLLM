/**
 * @name NoSQL Injection
 * @description Detects potential NoSQL injection vulnerabilities where user-controlled input
 *              is directly used to construct NoSQL queries without proper sanitization.
 * @kind path-problem
 * @precision high
 * @problem.severity error
 * @security-severity 8.8
 * @id py/nosql-injection
 * @tags security
 *       external/cwe/cwe-943
 */

// Import Python library for analyzing Python source code
import python
// Import the NoSQL injection analysis module
import semmle.python.security.dataflow.NoSqlInjectionQuery
// Import path graph class for representing data flow paths
import NoSqlInjectionFlow::PathGraph

// Select origin and target nodes from the path graph
from NoSqlInjectionFlow::PathNode origin, NoSqlInjectionFlow::PathNode target
// Condition: there exists a data flow path from the origin to the target
where NoSqlInjectionFlow::flowPath(origin, target)
// Select results: target node, origin node, target node, warning message, origin node, user input description
select target.getNode(), origin, target, "This NoSQL query contains an unsanitized $@.", origin,
  "user-provided value"