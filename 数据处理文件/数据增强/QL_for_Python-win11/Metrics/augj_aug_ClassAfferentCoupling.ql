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

// Extract the afferent coupling metric for each class with available metrics
// This metric represents the number of classes that depend on the analyzed class
from ClassMetrics analyzedClass, int incomingDependenciesCount
where incomingDependenciesCount = analyzedClass.getAfferentCoupling()
select analyzedClass, 
       incomingDependenciesCount 
order by incomingDependenciesCount desc