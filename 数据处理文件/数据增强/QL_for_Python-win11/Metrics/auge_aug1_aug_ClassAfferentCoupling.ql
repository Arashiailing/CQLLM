/**
 * @name Analysis of class incoming dependencies
 * @description Evaluates and counts the quantity of external classes that depend on each analyzed class.
 *              Higher counts represent classes with greater incoming dependencies, potentially
 *              impacting the system's modularity and ease of modification.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract classes that have measurable incoming dependencies from other classes
from ClassMetrics analyzedClass
where exists(analyzedClass.getAfferentCoupling())
// Present each class with its corresponding count of incoming dependencies,
// arranged from highest to lowest dependency count for emphasis on heavily relied-upon classes
select analyzedClass, 
       analyzedClass.getAfferentCoupling() as incomingDependencyCount 
order by incomingDependencyCount desc