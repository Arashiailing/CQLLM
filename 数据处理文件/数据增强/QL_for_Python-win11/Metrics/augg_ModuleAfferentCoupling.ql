/**
 * @name Incoming module dependencies
 * @description Calculates the afferent coupling for each module, representing
 *              the count of other modules that depend on it. Higher values indicate
 *              modules that are more central to the codebase and potentially harder to modify.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python

// Extract module metrics to analyze dependency relationships
from ModuleMetrics moduleMetric
// Compute and retrieve the incoming dependency count for each module
select moduleMetric, moduleMetric.getAfferentCoupling() as dependencyCount order by dependencyCount desc