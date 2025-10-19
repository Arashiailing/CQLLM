/**
 * @name CWE-684: Incorrect Provision of Specified Functionality
 * @id py/webkittab
 */

import python
import semmle.python.security.dataflow.ReflectedXssQuery

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential reflected XSS vulnerability at $@.", source.getNode()