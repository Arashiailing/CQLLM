/**
 * @name Module dependency analysis
 * @description Quantifies and visualizes the afferent coupling (incoming dependencies) for each Python module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module dependencies by quantifying incoming dependencies for each module
from ModuleMetrics moduleMetrics, int incomingDependencyCount
where 
  // Compute the afferent coupling (number of incoming dependencies) for the module
  incomingDependencyCount = moduleMetrics.getAfferentCoupling()
  // Focus only on modules that have at least one incoming dependency
  and incomingDependencyCount > 0
select 
  moduleMetrics, 
  incomingDependencyCount as dependencyCount 
order by 
  dependencyCount desc