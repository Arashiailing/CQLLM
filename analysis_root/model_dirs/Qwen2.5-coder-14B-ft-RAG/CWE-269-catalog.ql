/**
 * @name CWE-269: Improper Privilege Management
 * @description The product does not properly assign, modify, track, or check privileges for an actor, creating an unintended sphere of control for that actor.
 * @kind treemap
 * @treemap.warnOnHighValues true
 * @metricType problem
 * @id py/catalog
 */

import python

from Import i, int priv_count
where
  (
    i = API::moduleImport("privileges").getAnImport() and
    priv_count = i.getScope().getMetrics().nFunctions()
  )
  or
  (
    i = API::moduleImport("policy").getAnImport() and
    priv_count = i.getScope().getMetrics().nFunctions()
  )
select i.getFile(), priv_count