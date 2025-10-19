/**
 * @name HTTP Response Splitting
 * @description Detects vulnerabilities where user-controlled input
 *              is directly written to HTTP headers, enabling
 *              header splitting attacks.
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

// Define data flow source node representing user input
from HeaderInjectionFlow::PathNode originNode,
     // Define data flow sink node representing vulnerable header operation
     HeaderInjectionFlow::PathNode targetNode

// Filter source-sink pairs with actual data flow paths
where HeaderInjectionFlow::flowPath(originNode, targetNode)

// Generate results with sink location, flow path, and vulnerability description
select targetNode.getNode(), originNode, targetNode, 
       "This HTTP header is constructed from a $@.", 
       originNode.getNode(), "user-provided value"