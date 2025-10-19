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

// Extract classes with measurable afferent coupling and their dependency count
from ClassMetrics analyzedClass, int couplingCount
where couplingCount = analyzedClass.getAfferentCoupling() and exists(couplingCount)
select analyzedClass, 
       couplingCount as dependencyCount 
order by dependencyCount desc