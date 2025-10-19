/**
 * @name CWE-134: Use of Externally-Controlled Format String
 * @description The product uses a function that accepts a format string as an argument, but the format string originates from an external source.
 * @id py/nodes
 */

import python
import semmle.python.security.dataflow.LogInjectionQuery

from LogInjectionFlow::PathNode source, LogInjectionFlow::PathNode sink
where LogInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This log entry depends on a $@.", source.getNode(), "user-provided value"