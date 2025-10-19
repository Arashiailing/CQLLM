/**
 * @name Class Dependency Analysis
 * @description Analyzes the afferent coupling metric for classes, which quantifies the number of
 *              external classes that depend on a given class. Higher afferent coupling values
 *              indicate classes that are more central to the codebase and may necessitate
 *              more careful consideration during modifications.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with measurable afferent coupling
from ClassMetrics analyzedClass
where exists(analyzedClass.getAfferentCoupling())
// Calculate and output the coupling count for each class, ordered by centrality
select analyzedClass, 
       analyzedClass.getAfferentCoupling() as couplingCount 
order by couplingCount desc