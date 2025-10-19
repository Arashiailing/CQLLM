/**
 * @name Class Dependency Analysis
 * @description Identifies the afferent coupling metric for classes, measuring how many
 *              other classes depend on each class. Classes with higher afferent coupling
 *              are typically more central and may require more careful modification.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Filter classes with measurable afferent coupling
from ClassMetrics targetClass
where exists(targetClass.getAfferentCoupling())
// Output each class with its dependency count, ordered by centrality
select targetClass, 
       targetClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc