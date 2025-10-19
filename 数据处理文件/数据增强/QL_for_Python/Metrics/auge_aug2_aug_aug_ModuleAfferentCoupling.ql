/**
 * @name Module dependency analysis
 * @description Assesses and visualizes the number of incoming dependencies for each module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Evaluate module interdependencies by measuring incoming connections
from ModuleMetrics moduleStats, int incomingDeps
where 
  // Determine the afferent coupling (incoming dependencies) for each module
  incomingDeps = moduleStats.getAfferentCoupling()
  // Exclude modules without any incoming dependencies
  and incomingDeps > 0
select 
  moduleStats, 
  incomingDeps as couplingMetric 
order by 
  couplingMetric desc