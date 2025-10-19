/**
 * @name Class Dependency Analysis
 * @description Calculates afferent coupling for classes, quantifying the number of
 *              external dependencies each class has. Higher values indicate classes
 *              that are more central to the codebase and require careful modification.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with quantifiable afferent coupling
from ClassMetrics measuredClass 
where exists(measuredClass.getAfferentCoupling())
// Output classes sorted by dependency count (highest first)
select measuredClass, 
       measuredClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc