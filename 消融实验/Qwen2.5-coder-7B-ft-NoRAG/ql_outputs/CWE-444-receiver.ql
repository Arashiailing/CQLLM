/**
 * @name CWE-444: Inconsistent Interpretation of HTTP Requests ('HTTP Request/Response Smuggling')
 * @description nan
 * @id py/receiver
 */

import python
import semmle.python.security.dataflow.ReflectedXssQuery
import ReflectedXssFlow::PathGraph

from ReflectedXssFlow::PathNode source, ReflectedXssFlow::PathNode sink
where ReflectedXssFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Potential HTTP request/response smuggling vulnerability due to inconsistent interpretation of HTTP requests."