/**
 * @name Class Afferent Coupling Analysis
 * @description Calculates the afferent coupling metric for each class, which counts the number of classes that depend on it.
 *              High afferent coupling suggests a class is a central component, making it harder to change without
 *              impacting many parts of the system. This metric is vital for evaluating modularity.
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
  targetClass.getAfferentCoupling() as afferentCouplingCount
order by afferentCouplingCount desc