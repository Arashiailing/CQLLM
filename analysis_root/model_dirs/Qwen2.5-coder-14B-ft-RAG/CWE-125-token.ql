/**
 * @name CWE-125: Out-of-bounds Read
 * @description The product reads data past the end, or before the beginning, of the intended buffer.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.8
 * @sub-severity low
 * @precision high
 * @id py/out-of-bounds-read
 * @tags correctness
 *       security
 *       external/cwe/cwe-125
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "This path depends on a $@.", source.getNode(), "user-provided value"