/**
 * @name Class Dependency Inflow Analysis
 * @description Identifies the count of classes that have dependencies on each target class (afferent coupling).
 *              Functions as a modularity evaluation metric by emphasizing classes with substantial incoming dependencies.
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
where exists(targetClass.getAfferentCoupling())
select 
  targetClass,
  targetClass.getAfferentCoupling() as dependencyCount
order by dependencyCount desc