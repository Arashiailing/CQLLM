/**
 * @name HTTP Response Splitting
 * @description Detects vulnerabilities where user-controlled input is directly
 *              written to HTTP headers, enabling header splitting attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Import core Python analysis library
import python

// Import specialized HTTP header injection analysis module
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Import path graph representation for taint flow visualization
import HeaderInjectionFlow::PathGraph

// Define taint flow source and sink variables
from HeaderInjectionFlow::PathNode taintedSource, HeaderInjectionFlow::PathNode headerSink

// Filter for valid taint propagation paths between sources and sinks
where HeaderInjectionFlow::flowPath(taintedSource, headerSink)

// Generate alert with vulnerable sink node, flow path, and contextual message
select headerSink.getNode(), taintedSource, headerSink, 
       "This HTTP header is constructed from a $@.", 
       taintedSource.getNode(), 
       "user-provided value"