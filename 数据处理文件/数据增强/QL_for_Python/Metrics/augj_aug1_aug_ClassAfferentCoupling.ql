/**
 * @name Incoming class dependencies analysis
 * @description Analyzes and quantifies the number of external classes depending on each target class. 
 *              Higher values indicate classes with more incoming dependencies, impacting modularity.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract classes with measurable incoming dependencies
from ClassMetrics targetClass
where exists(targetClass.getAfferentCoupling())
// Display each target class and its incoming dependency count, sorted by highest values first
select targetClass, 
       targetClass.getAfferentCoupling() as incomingDependencyCount 
order by incomingDependencyCount desc