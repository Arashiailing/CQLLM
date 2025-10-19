/**
 * @name Module dependency analysis
 * @description Evaluates and visualizes the count of incoming dependencies for each module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Define data sources: module metrics and dependency count
from ModuleMetrics moduleStats, int depCount
where 
  // Compute the afferent coupling (number of incoming dependencies)
  depCount = moduleStats.getAfferentCoupling()
  // Filter out modules with no incoming dependencies
  and depCount > 0
select 
  moduleStats, 
  depCount as couplingValue 
order by 
  couplingValue desc