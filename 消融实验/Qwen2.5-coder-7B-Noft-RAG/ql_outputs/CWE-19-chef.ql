/**
* @name CWE-19: Comm
    and Injection Query
*
@description Detects instances
    where user-controlled inputs are used in comm
    and lines.
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @precision high
*
@id py/command-line-injection
*
@tags security * external/cwe/cwe-078 * external/cwe/cwe-088
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"