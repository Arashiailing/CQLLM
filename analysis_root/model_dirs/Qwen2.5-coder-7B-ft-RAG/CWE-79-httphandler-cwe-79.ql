/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/httphandler-cwe-79
 * @tags security
 *       external/cwe/cwe-079
 */

import python
import semmle.python.security.dataflow.HttpServerSideRequestHandlingDataFlow
import HttpServerSideRequestHandlingDataFlow::PathGraph

from HttpServerSideRequestHandlingDataFlow::PathNode source,
     HttpServerSideRequestHandlingDataFlow::PathNode sink
where HttpServerSideRequestHandlingDataFlow::flowPath(source, sink)
select sink.getNode(),
       source,
       sink,
       "Cross-site scripting vulnerability due to a $@.",
       source.getNode(),
       "user-provided value"