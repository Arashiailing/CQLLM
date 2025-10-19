/**
 * @name Class Dependency Inflow Analysis
 * @description Measures and counts how many external classes rely on each target class.
 *              Elevated counts signify classes with greater incoming dependencies, affecting modularity.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with measurable incoming dependencies and their counts
from ClassMetrics targetClass, int incomingDependencyCount
where incomingDependencyCount = targetClass.getAfferentCoupling() and
      exists(incomingDependencyCount)
// Select each class and its incoming dependency count, ordered by highest count first
select targetClass, 
       incomingDependencyCount 
order by incomingDependencyCount desc