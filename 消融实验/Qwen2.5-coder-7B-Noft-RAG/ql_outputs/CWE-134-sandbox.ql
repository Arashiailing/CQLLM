/**
* @name CWE-134: Use of Externally-Controlled Format String
*
@description The product uses a function that accepts a format string as an argument, * but the format string originates
from an external source.
*
@id py/sandbox
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"