/**
 * @name CWE CATEGORY: 7PK - Security Features
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.3
 * @id py/core-cwe-254
 */

import python
import semmle.python.security.dataflow.CodeInjectionQuery
import CodeInjectionFlow::PathGraph

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(),  "user-provided value"