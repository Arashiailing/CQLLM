/**
 * @name HTTP Response Splitting
 * @description Identifies vulnerabilities where user-controlled input
 *              is directly written to HTTP headers, enabling
 *              CRLF injection attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Import Python analysis framework
import python

// Import HTTP header injection detection logic
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Import path graph representation for data flow tracking
import HeaderInjectionFlow::PathGraph

// Identify source-sink pairs with data flow paths
from HeaderInjectionFlow::PathNode sourceNode,
     HeaderInjectionFlow::PathNode sinkNode
where HeaderInjectionFlow::flowPath(sourceNode, sinkNode)

// Generate results with sink location, flow path, and vulnerability description
select sinkNode.getNode(), sourceNode, sinkNode, 
       "This HTTP header is constructed from a $@.", 
       sourceNode.getNode(), "user-provided value"