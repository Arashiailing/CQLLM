/**
 * @name Class Afferent Coupling Analysis
 * @description Measures the afferent coupling metric for each class, indicating how many other classes depend on it.
 *              High afferent coupling values suggest central components that may require careful modification
 *              due to their widespread impact on the system's modularity and maintainability.
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