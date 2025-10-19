/**
* @name CWE-684: Incorrect Provision of Specified Functionality
*
@id py/browsertab
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Incorrect provision of specified functionality depends on a $@.", source.getNode(), "user-provided value"