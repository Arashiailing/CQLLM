/**
* @name CWE-20: Comm
    and Injection
*
@description Improper input validation leading to comm
    and injection.
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @precision high
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