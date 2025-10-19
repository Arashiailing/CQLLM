/**
 * @name CWE-59: Improper Link Resolution Before File Access ('Link Following')
 * @description nan
 * @kind path-problem
 * @problem.severity error
 * @security-severity 7.5
 * @precision high
 * @id py/zone
 */

import python
import semmle.python.security.dataflow.ZoneSubstitutionQuery
import ZoneSubstitutionFlow::PathGraph

from ZoneSubstitutionFlow::PathNode source, ZoneSubstitutionFlow::PathNode sink
where ZoneSubstitutionFlow::flowPath(source, sink)
select sink.getNode(), source, sink, "Zone substitution occurs before this $@", source,
  "user-controlled value"