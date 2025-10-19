/**
 * @name CWE-20: Improper Input Validation
 * @description The product receives input or data, but it does
 *              not validate or incorrectly validates that the input has the
 *              properties that are required to process the data safely and
 *              correctly.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @security-severity 9.1
 * @id py/code-injection
 * @tags security
 *       external/cwe/cwe-020
 */

import python
import semmle.python.security.dataflow.CodeInjectionQuery
import CodeInjectionFlow::PathGraph

from CodeInjectionFlow::PathNode source, CodeInjectionFlow::PathNode sink
where CodeInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This code execution depends on a $@.", source.getNode(),  
  "user-provided value"