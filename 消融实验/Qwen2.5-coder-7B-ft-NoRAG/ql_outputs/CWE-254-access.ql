/**
 * @name CWE-254: Code Injection Query
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/code-injection-query
 * @tags security
 */
import python
import semmle.python.security.dataflow.CodeInjectionQuery

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(), "user-provided value"