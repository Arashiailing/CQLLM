/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/link-following
 * @tags security
 *       external/cwe/cwe-59
 */

import python
import semmle.python.security.dataflow.PathInjectionQuery
import PathInjectionFlow::PathGraph

from PathInjectionFlow::PathNode source, PathInjectionFlow::PathNode sink
where PathInjectionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Improper link resolution before file access detected.", source.getNode(), "untrusted input"