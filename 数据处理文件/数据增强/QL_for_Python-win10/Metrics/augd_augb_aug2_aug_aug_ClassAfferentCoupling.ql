/**
 * @name Class Dependency Inflow Measurement
 * @description Measures the inflow dependency for each class, which counts how many other classes rely on it.
 *              This metric is essential for evaluating software modularity, as classes with high dependency inflow
 *              often represent core components that might be difficult to change without impacting numerous system areas.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics evaluatedClass
where exists(evaluatedClass.getAfferentCoupling())
select 
  evaluatedClass,
  evaluatedClass.getAfferentCoupling() as incomingCouplingMetric
order by incomingCouplingMetric desc