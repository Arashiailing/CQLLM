/**
 * @name HTTP Response Splitting
 * @description Detects security flaws where untrusted user input is
 *              directly placed into HTTP headers, which can lead to
 *              CRLF injection vulnerabilities.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/http-response-splitting
 * @tags security
 *       external/cwe/cwe-113
 *       external/cwe/cwe-079
 */

// Import the Python analysis framework
import python

// Import the detection logic for HTTP header injection
import semmle.python.security.dataflow.HttpHeaderInjectionQuery

// Import the path graph for tracking data flow
import HeaderInjectionFlow::PathGraph

// Find pairs of source and sink nodes that are connected by a data flow path
from HeaderInjectionFlow::PathNode injectionSource,
     HeaderInjectionFlow::PathNode headerSink
where HeaderInjectionFlow::flowPath(injectionSource, headerSink)

// Output the results, including the sink's location, the flow path, and a message
select headerSink.getNode(), injectionSource, headerSink, 
       "This HTTP header is constructed from a $@.", 
       injectionSource.getNode(), "user-provided value"