/**
* @name CWE-20: Improper Input Validation
*
@description The product receives input
    or data, but it does * not validate
    or incorrectly validates that the input has the * properties that are required to process the data safely
    and * correctly.
*
@id py/IcnsImagePlugin
*/
import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph
from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
    where PathInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This path depends on a $@.", source.getNode(), "user-provided value"