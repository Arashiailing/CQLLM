/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/htmlserializer
 */

import python
import semmle.python.security.dataflow.HtmlSerializerQuery
import HtmlSerializerFlow::PathGraph

from HtmlSerializerFlow::PathNode source, HtmlSerializerFlow::PathNode sink
where HtmlSerializerFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "HTML serialization depends on a $@.", source.getNode(), "user-provided value"