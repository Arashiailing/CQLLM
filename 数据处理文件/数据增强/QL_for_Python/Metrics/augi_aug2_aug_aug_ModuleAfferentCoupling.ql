/**
 * @name Module dependency analysis
 * @description Evaluates and displays the count of incoming dependencies per module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module dependencies by computing incoming dependency counts
from ModuleMetrics moduleInfo, int incomingDeps
where 
  // Compute the number of incoming dependencies for each module
  incomingDeps = moduleInfo.getAfferentCoupling()
  // Exclude modules that have no incoming dependencies
  and incomingDeps > 0
select 
  moduleInfo, 
  incomingDeps as depCount 
order by 
  depCount desc