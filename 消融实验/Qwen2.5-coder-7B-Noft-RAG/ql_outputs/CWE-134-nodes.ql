/**
* @name CWE-134: Use of Externally-Controlled Format String
*
@id py/format-string-injection
*/
import python
import semmle.python.security.dataflow.FormatStringInjectionQuery
import FormatStringInjectionFlow::PathGraph
from FormatStringInjectionFlow::PathNode source, FormatStringInjectionFlow::PathNode sink
    where FormatStringInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This format string depends on a $@.", source.getNode(), "user-provided value"