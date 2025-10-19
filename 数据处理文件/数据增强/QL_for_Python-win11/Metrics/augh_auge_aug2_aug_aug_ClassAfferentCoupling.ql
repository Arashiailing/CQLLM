/**
 * @name Class Dependency Inflow Analysis
 * @description This query calculates the count of classes that have dependencies on each target class (afferent coupling).
 *              It functions as a modularity evaluation metric by identifying classes with excessive incoming dependencies.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics targetClass
where targetClass.getAfferentCoupling() > 0
select 
  targetClass,
  targetClass.getAfferentCoupling() as dependencyCount
order by dependencyCount desc