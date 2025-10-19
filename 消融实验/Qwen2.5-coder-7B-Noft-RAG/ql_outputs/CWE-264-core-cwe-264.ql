/**
* @name CWE-264: Comm
    and Injection Query
* @kind path-problem
* @problem.severity error
* @precision high
* @security-severity 9.8
*
@id py/core-cwe-264
*
@tags security
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"