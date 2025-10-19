/**
 * @name Class Afferent Coupling Analysis
 * @description Computes the afferent coupling metric for each class, representing the number of classes that depend on it.
 *              This metric is crucial for modularity assessment, as classes with high afferent coupling may indicate
 *              central components that could be challenging to modify without affecting multiple parts of the system.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics analyzedClass
where exists(analyzedClass.getAfferentCoupling())
select 
  analyzedClass,
  analyzedClass.getAfferentCoupling() as afferentCouplingCount
order by afferentCouplingCount desc