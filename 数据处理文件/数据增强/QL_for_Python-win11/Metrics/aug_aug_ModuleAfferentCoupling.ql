/**
 * @name Module dependency analysis
 * @description Calculates and displays the count of incoming dependencies for each module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module dependencies by calculating incoming dependency counts
from ModuleMetrics moduleMetric, int dependencyCount
where 
  // Only process modules with at least one incoming dependency
  dependencyCount = moduleMetric.getAfferentCoupling() and
  dependencyCount > 0
select 
  moduleMetric, 
  dependencyCount as couplingCount 
order by 
  couplingCount desc