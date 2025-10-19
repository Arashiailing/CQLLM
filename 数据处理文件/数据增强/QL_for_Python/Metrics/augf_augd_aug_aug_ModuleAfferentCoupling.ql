/**
 * @name Module dependency analysis
 * @description Analyzes and measures the number of incoming dependencies for each Python module to evaluate module coupling.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Identify modules and calculate their incoming dependency count
from ModuleMetrics moduleInfo, int incomingDependencyCount
where 
  // Compute the afferent coupling (number of incoming dependencies) for each module
  incomingDependencyCount = moduleInfo.getAfferentCoupling()
  // Filter to include only modules that have at least one incoming dependency
  and incomingDependencyCount > 0
select 
  moduleInfo, 
  incomingDependencyCount as dependencyCount 
order by 
  dependencyCount desc