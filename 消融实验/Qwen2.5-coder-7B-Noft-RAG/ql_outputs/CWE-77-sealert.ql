/**
* @name CWE-77: Improper Neutralization of Special Elements used in a Comm
    and ('Comm
    and Injection')
*
@description The product constructs all
    or part of a comm
    and using externally-influenced input
from an upstream component, but it does not neutralize
    or incorrectly neutralizes special elements that could modify the intended comm
    and when it is sent to a downstream component.
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @sub-severity high
* @precision high
*
@id py/sealert
*/
import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
import UnsafeShellCommandConstructionFlow::PathGraph
from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
    where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"