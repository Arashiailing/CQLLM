/**
 * @name Incoming module dependencies
 * @description Determines the afferent coupling metric for each module, which measures
 *              how many other modules depend on it. Modules with higher values are typically
 *              more critical components and may be more difficult to change without side effects.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Analyze module dependency relationships by extracting metrics for each module
from ModuleMetrics moduleData
// Calculate the number of incoming dependencies (afferent coupling) for the module
where exists(moduleData.getAfferentCoupling())
// Order results by dependency count in descending order to highlight most depended-upon modules
select moduleData, moduleData.getAfferentCoupling() as incomingDependencyCount order by incomingDependencyCount desc