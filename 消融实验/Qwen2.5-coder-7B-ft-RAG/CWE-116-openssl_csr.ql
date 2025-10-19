/**
 * @name Path Injection
 * @description Injecting code into a command line argument may cause arbitrary code execution.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 9.1
 * @precision high
 * @id py/path-injection
 * @tags security
 *       external/cwe/cwe-078
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Command-line argument depends on a $@.", source.getNode(),
  "user-provided value"