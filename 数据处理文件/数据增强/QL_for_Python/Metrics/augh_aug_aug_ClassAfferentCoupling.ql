/**
 * @name Analysis of incoming class dependencies
 * @description This query identifies and counts the number of classes that depend on each target class,
 *              providing insight into the afferent coupling metric for modularity assessment.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract target classes with valid afferent coupling metrics
from ClassMetrics targetClass, int dependencyCount
where 
  // Calculate dependency count for each class
  dependencyCount = targetClass.getAfferentCoupling() and
  // Ensure only classes with measurable dependencies are considered
  exists(dependencyCount)
select 
  targetClass, 
  dependencyCount 
order by 
  dependencyCount desc