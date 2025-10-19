/**
* @name CWE-254: Code Injection
* @kind path-problem
* @problem.severity error
* @security-severity 9.3
* @precision high
*
@id py/code-injection
*
@tags security * external/cwe/cwe-254
*/
import python
import semmle.python.security.dataflow.CodeInjectionQuery
from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
    where CodeInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"