/**
 * @name HTTP Response Splitting
 * @description Detects vulnerabilities where untrusted user input
 *              is directly embedded in HTTP headers, facilitating
 *              CRLF injection and cross-site scripting attacks.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Core Python analysis framework
import python

// HTTP header injection vulnerability detection logic
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Path graph representation for tracking data flow
import HeaderInjectionFlow::PathGraph

// Identify vulnerable data flow paths from source to sink
from HeaderInjectionFlow::PathNode taintedSource,
     HeaderInjectionFlow::PathNode headerSink
where HeaderInjectionFlow::flowPath(taintedSource, headerSink)

// Report vulnerability with sink location, flow path, and context
select headerSink.getNode(), taintedSource, headerSink,
       "This HTTP header incorporates a $@.",
       taintedSource.getNode(), "user-controlled input"