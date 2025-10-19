/**
* @name CWE-254: Code Injection
* @category 7PK - Security Features
*
@description Detects instances
    where user-controlled data is used to construct a comm
    and line, which can lead to comm
    and injection vulnerabilities.
*
@id py/code-injection
*/
import python
import semmle.python.security.dataflow.CommandInjectionQuery
from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
    where CommandInjectionFlow::flowPath(source, sink)
    select sink.getNode(), source, sink, "This comm
    and line depends on a $@.", source.getNode(), "user-provided value"