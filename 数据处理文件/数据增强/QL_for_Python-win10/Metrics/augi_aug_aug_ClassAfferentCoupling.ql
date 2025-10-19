/**
 * @name Analysis of incoming class dependencies
 * @description Identifies and quantifies classes that depend on each target class,
 *              providing afferent coupling metrics to evaluate modularity and change impact.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract target classes with valid afferent coupling measurements
from ClassMetrics targetClass, int dependencyCount
where dependencyCount = targetClass.getAfferentCoupling()
select targetClass, 
       dependencyCount 
order by dependencyCount desc