/**
 * @deprecated
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description nan
 * @kind path-problem
 * @id py/chroot
 * @problem.severity warning
 * @tags external/cwe/cwe-59
 */

import python
import semmle.python.ApiGraphs
import semmle.python.security.dataflow.LinkFollowingQuery

from LinkFollowingFlow::PathNode source, LinkFollowingFlow::PathNode sink
where LinkFollowingFlow::flowPath(source, sink)
select sink.getNode(), source, sink,
  "$@ reaches this location and it is later used in a relative import.", source.getNode(),
  "A link"