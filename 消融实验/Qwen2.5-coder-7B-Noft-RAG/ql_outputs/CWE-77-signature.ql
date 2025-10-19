/**
* @name CWE-77: Improper Neutralization of Special Elements used in a Comm
    and ('Comm
    and Injection')
*
@description The product constructs all
    or part of a comm
    and using externally-influenced input
from an upstream component, * but it does not neutralize
    or incorrectly neutralizes special elements that could modify the intended comm
    and when it is * sent to a downstream component.
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @precision high
*
@id py/command-line-injection
*
@tags correctness * security * external/cwe/cwe-078 * external/cwe/cwe-088
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"