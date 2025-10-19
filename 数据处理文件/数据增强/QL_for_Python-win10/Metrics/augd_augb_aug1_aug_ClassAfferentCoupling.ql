/**
 * @name Inbound Dependency Analysis for Classes
 * @description Quantifies the number of external classes that depend on each analyzed class.
 *              Higher values indicate classes with more incoming dependencies, impacting system modularity.
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
from ClassMetrics analyzedClass, int dependencyInflowCount
where 
  dependencyInflowCount = analyzedClass.getAfferentCoupling() and
  dependencyInflowCount > 0
// Select each class and its incoming dependency count, ordered by highest count first
select 
  analyzedClass, 
  dependencyInflowCount 
order by 
  dependencyInflowCount desc