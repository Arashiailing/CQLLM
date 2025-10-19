/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @id py/link-resolution-before-file-access
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @tags security
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper link resolution before file access detected."