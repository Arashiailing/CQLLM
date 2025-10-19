/**
 * @name CWE-264: Command Injection
 * @id py/core-cwe-264
 */
import python
import semmle.python.security.dataflow.CommandInjectionQuery
import CommandInjectionFlow::PathGraph

from CommandInjectionFlow::PathNode source, CommandInjectionFlow::PathNode sink
where CommandInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Command injection vulnerability detected: $@.", source.getNode()