/**
 * @name Incoming class dependencies
 * @description Quantifies the number of classes that depend on each class, measuring external dependencies.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Calculate afferent coupling for each class metric and order results by dependency count in descending order
from ClassMetrics classMetric, int dependencyCount
where dependencyCount = classMetric.getAfferentCoupling()
select classMetric, dependencyCount order by dependencyCount desc