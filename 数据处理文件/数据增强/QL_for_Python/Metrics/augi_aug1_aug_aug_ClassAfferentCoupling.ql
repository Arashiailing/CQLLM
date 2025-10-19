/**
 * @name Analysis of incoming class dependencies
 * @description This query evaluates the afferent coupling for each class,
 *              which measures the count of other classes relying on it.
 *              Elevated values signify classes that play a more pivotal role in the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with quantifiable incoming dependencies and calculate their dependency count
from ClassMetrics targetClass, int inboundDependencyCount
where 
  // Calculate the number of classes that depend on the target class
  inboundDependencyCount = targetClass.getAfferentCoupling()
  // Ensure we only consider classes with measurable dependencies
  and exists(inboundDependencyCount)
select 
  targetClass, 
  inboundDependencyCount as inboundDeps 
order by 
  inboundDeps desc