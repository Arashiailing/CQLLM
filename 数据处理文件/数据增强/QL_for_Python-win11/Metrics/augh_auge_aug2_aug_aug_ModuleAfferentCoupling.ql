/**
 * @name Module dependency analysis
 * @description Quantifies and displays the count of incoming dependencies for each module, helping identify highly coupled components.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module connectivity by calculating inbound dependency relationships
from ModuleMetrics moduleInfo, int dependencyCount
where 
  // Calculate the afferent coupling metric (number of modules that depend on this one)
  dependencyCount = moduleInfo.getAfferentCoupling()
  // Filter out modules with zero incoming dependencies to focus on meaningful connections
  and dependencyCount > 0
select 
  moduleInfo, 
  dependencyCount as couplingMetric 
order by 
  couplingMetric desc