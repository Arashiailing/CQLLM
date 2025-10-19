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

// Perform module dependency assessment by calculating incoming dependency counts
from ModuleMetrics moduleData, int afferentCoupling
where 
  // Calculate the afferent coupling (incoming dependencies) for each module
  afferentCoupling = moduleData.getAfferentCoupling()
  // Filter out modules with no incoming dependencies
  and afferentCoupling > 0
select 
  moduleData, 
  afferentCoupling as couplingValue 
order by 
  couplingValue desc