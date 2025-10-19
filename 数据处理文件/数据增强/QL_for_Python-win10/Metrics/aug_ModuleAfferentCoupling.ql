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

// Define the main query to analyze module dependencies
from ModuleMetrics m
where m.getAfferentCoupling() > 0 // Only consider modules with at least one incoming dependency
select m, m.getAfferentCoupling() as couplingCount 
order by couplingCount desc