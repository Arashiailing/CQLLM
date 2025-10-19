/**
 * @name Module dependency analysis
 * @description Quantifies and visualizes the number of incoming dependencies for each Python module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Extract module dependency metrics and filter for modules with incoming dependencies
from ModuleMetrics moduleStats, int incomingDeps
where 
  // Calculate afferent coupling (incoming dependencies) and ensure at least one exists
  incomingDeps = moduleStats.getAfferentCoupling() and
  incomingDeps > 0
select 
  moduleStats, 
  incomingDeps as dependencyCount 
order by 
  dependencyCount desc