/**
 * @name Class dependency inflow analysis
 * @description Measures and calculates the count of outside classes that rely on each analyzed class.
 *              Elevated counts signify classes with greater incoming dependencies, affecting modular design.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Define the main query to analyze class dependencies
from ClassMetrics targetClass
// Ensure we only consider classes with measurable incoming dependencies
where exists(targetClass.getAfferentCoupling())
// Project the class and its dependency count, ordered by highest dependency first
select targetClass, 
       targetClass.getAfferentCoupling() as incomingDependencyCount 
order by incomingDependencyCount desc