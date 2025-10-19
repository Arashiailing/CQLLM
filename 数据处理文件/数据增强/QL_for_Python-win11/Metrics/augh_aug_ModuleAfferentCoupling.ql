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

// Identify modules with external dependencies and analyze their coupling metrics
from ModuleMetrics modMetric
where 
  // Filter for modules that have at least one incoming dependency
  exists(modMetric.getAfferentCoupling()) and 
  modMetric.getAfferentCoupling() > 0
select 
  modMetric, 
  modMetric.getAfferentCoupling() as incomingDeps 
order by 
  incomingDeps desc