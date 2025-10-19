/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 6.1
 * @precision high
 * @id py/reviewtags
 */

import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Cross-site scripting vulnerability due to a $@.", source.getNode(), "user-provided value"