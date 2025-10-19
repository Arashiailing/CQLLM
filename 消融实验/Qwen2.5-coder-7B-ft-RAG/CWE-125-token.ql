/**
 * @name CWE-125: Out-of-bounds Read
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @kind path-problem
 * @id py/token
 * @problem.severity error
 * @security-severity 7.5
 * @precision medium
 * @tags security
 *       external/cwe/cwe-125
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Out-of-bound read at $@.", source.getNode(),
  "uncontrolled index value"