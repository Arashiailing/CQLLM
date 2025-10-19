/**
 * @name Module dependency analysis
 * @description Computes and visualizes the number of incoming dependencies for each module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module dependencies by counting incoming references from other modules
from ModuleMetrics moduleInfo, int incomingDeps
where 
  // Calculate the afferent coupling (incoming dependencies) for each module
  incomingDeps = moduleInfo.getAfferentCoupling() and
  // Focus analysis on modules that have at least one incoming dependency
  incomingDeps > 0
select 
  moduleInfo, 
  incomingDeps as dependencyCount 
order by 
  dependencyCount desc