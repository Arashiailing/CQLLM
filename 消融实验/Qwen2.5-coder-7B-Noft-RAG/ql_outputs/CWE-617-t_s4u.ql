/**
* @name CWE-617: Comm
    and Injection
*
@description Using externally controlled strings in a comm
    and line may allow a malicious * user to change the meaning of the command.
* @kind path-problem
* @problem.severity error
* @security-severity 9.8
* @sub-severity high
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