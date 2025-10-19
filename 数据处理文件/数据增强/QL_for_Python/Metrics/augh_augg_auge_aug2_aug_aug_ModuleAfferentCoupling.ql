/**
 * @name Module dependency analysis
 * @description Quantifies and visualizes incoming dependencies per module to identify highly coupled components.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module coupling by counting incoming dependencies
from ModuleMetrics moduleInfo, int incomingDependencyCount
where 
  // Calculate the number of modules depending on this module
  incomingDependencyCount = moduleInfo.getAfferentCoupling()
  // Focus only on modules with actual dependencies
  and incomingDependencyCount > 0
select 
  moduleInfo, 
  incomingDependencyCount as dependencyCount 
order by 
  dependencyCount desc