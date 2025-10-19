/**
 * @name Analysis of incoming class dependencies
 * @description This query calculates the afferent coupling for each class,
 *              which represents the number of other classes that depend on it.
 *              Higher values indicate classes that are more central to the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes and calculate their incoming dependencies
from ClassMetrics targetClass, int dependencyCount
where 
  // Compute the number of classes that depend on the target class
  dependencyCount = targetClass.getAfferentCoupling() 
  // Ensure we only process classes with measurable dependencies
  and dependencyCount > 0
select targetClass, 
       dependencyCount 
order by dependencyCount desc