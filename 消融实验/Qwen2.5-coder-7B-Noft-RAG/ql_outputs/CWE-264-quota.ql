/**
* @name CWE-264: Comm
    and Injection
* @category Permissions, Privileges,
    and Access Controls
*
@description Detects instances
    where user-controlled input is used in a comm
    and line.
*
@id py/command-line-injection
*
@tags security
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"