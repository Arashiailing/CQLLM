/**
 * @name HTTP Response Splitting
 * @description Directly embedding user input into HTTP headers
 *              creates vulnerability to header splitting attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Core Python analysis module for code examination
import python

// Specialized module for HTTP header injection vulnerability analysis
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Path graph construction component for data flow tracking
import HeaderInjectionFlow::PathGraph

// Define data flow endpoints: origin and destination nodes
from HeaderInjectionFlow::PathNode originNode, HeaderInjectionFlow::PathNode destinationNode

// Filter node pairs with valid data flow propagation paths
where HeaderInjectionFlow::flowPath(originNode, destinationNode)

// Output results with vulnerability context and source tracking
select destinationNode.getNode(), originNode, destinationNode, "This HTTP header is constructed from a $@.", originNode.getNode(),
  "user-provided value"