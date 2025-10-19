/**
 * @name Reflected server-side cross-site scripting
 * @description Writing user input directly to a web page allows for a cross-site scripting vulnerability.
 * @id py/qutescheme
 */

import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This web page writes user input directly, which can lead to cross-site scripting vulnerabilities."