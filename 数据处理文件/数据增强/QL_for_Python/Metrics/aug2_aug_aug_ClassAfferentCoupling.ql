/**
 * @name Class Afferent Coupling Analysis
 * @description This query calculates the afferent coupling for each class, which is the count of classes that depend on it.
 *              It helps in assessing modularity by identifying classes with high incoming dependencies.
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