/**
* @name CWE-264: Unsafe Shell Comm
    and Construction
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @precision high
*
@id py/untrusted-shell-command-construction
*
@tags security * external/cwe/cwe-264
*/
import python
import semmle.python.security.dataflow.UnsafeShellCommandConstructionQuery
from UnsafeShellCommandConstructionFlow::PathNode source, UnsafeShellCommandConstructionFlow::PathNode sink
    where UnsafeShellCommandConstructionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "Unsafe shell comm
    and constructed
from user-controlled input."