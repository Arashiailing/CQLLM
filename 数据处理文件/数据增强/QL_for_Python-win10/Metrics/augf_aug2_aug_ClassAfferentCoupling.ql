/**
 * @name Incoming class dependencies analysis
 * @description Calculates and displays the count of classes that have dependencies on each target class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Retrieves the analyzed class from class metrics and extracts its incoming dependencies count
from ClassMetrics analyzedClass, int incomingDeps
where 
  // Calculate the afferent coupling (incoming dependencies) for the analyzed class
  incomingDeps = analyzedClass.getAfferentCoupling() 
  and 
  // Ensure the coupling count exists (is not null)
  exists(incomingDeps)
select 
  analyzedClass, 
  incomingDeps as dependencyCount 
order by 
  dependencyCount desc