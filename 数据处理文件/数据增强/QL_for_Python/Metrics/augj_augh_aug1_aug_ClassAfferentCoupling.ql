/**
 * @name Analysis of incoming class dependencies
 * @description Quantifies the number of external classes that depend on each target class.
 *              Higher values indicate classes with more incoming dependencies, which can impact modularity.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes for dependency analysis
from ClassMetrics analyzedClass
// Filter to include only classes that have measurable incoming dependencies
where exists(analyzedClass.getAfferentCoupling())
// Output the class and its incoming dependency count, sorted by highest dependency count
select analyzedClass, 
       analyzedClass.getAfferentCoupling() as dependencyInflowCount 
order by dependencyInflowCount desc