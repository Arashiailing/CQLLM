/**
 * @name Module Afferent Coupling Analysis
 * @description Computes the afferent coupling metric for each module, which measures
 *              how many other modules depend on it. Modules with higher afferent coupling
 *              are more critical in the codebase architecture and may be harder to change.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// This query identifies modules and calculates their afferent coupling,
// which represents the number of other modules that depend on them.
from ModuleMetrics moduleInfo
// Select each module along with its incoming dependency count,
// ordered from highest to lowest dependency count
select moduleInfo, moduleInfo.getAfferentCoupling() as incomingDeps order by incomingDeps desc