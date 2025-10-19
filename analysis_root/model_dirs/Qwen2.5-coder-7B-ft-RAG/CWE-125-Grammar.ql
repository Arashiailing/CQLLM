/**
 * @name CWE-125: Out-of-bounds Read
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @kind path-problem
 * @problem.severity error
 * @precision low
 * @security-severity 7.5
 * @id py/Grammar
 * @tags correctness
 *       security
 *       external/cwe/cwe-125
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Out-of-bound access depends on a $@", source.getNode(), "user-provided value"