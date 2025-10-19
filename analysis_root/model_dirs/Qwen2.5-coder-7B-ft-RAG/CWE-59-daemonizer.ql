/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description Detects instances where file system operations use symbolic links
 *              which could lead to unintended file accesses due to link traversal.
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/link-following
 * @tags security
 *       external/cwe/cwe-059
 */

import python
import semmle.python.security.dataflow.LinkFollowingQuery
import LinkFollowingFlow::PathGraph

from LinkFollowingFlow::PathNode source, LinkFollowingFlow::PathNode sink
where LinkFollowingFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "This file operation uses a $@", source.getNode(),
  "link resolution"