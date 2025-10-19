/**
* @name CWE-362: Concurrent Execution using Shared Resource with Improper Synchronization ('Race Condition')
*
@description The product contains a concurrent code sequence that requires temporary, exclusive access to a shared resource, * but a timing window exists in which the shared resource can be modified by another code sequence operating concurrently.
*
@id py/race-condition
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"