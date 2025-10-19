/**
 * @name Class Afferent Coupling Analysis
 * @description Computes the afferent coupling (Ca) metric for each class, representing the number of
 *              classes that depend on it. High afferent coupling indicates a class serves as a central
 *              architectural component, making it more resistant to changes due to widespread impact.
 *              This metric is essential for evaluating software modularity and identifying critical
 *              design elements that require careful maintenance.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics subjectClass
where exists(subjectClass.getAfferentCoupling())
select 
  subjectClass,
  subjectClass.getAfferentCoupling() as incomingDependencies
order by incomingDependencies desc