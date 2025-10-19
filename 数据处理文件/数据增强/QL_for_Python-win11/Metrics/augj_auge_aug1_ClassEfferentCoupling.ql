/**
 * @name External class dependencies analysis
 * @description Measures the count of unique external classes that each class relies upon.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// This query determines the efferent coupling metric for individual classes,
// indicating how many distinct external classes each class depends on.
// Higher values suggest stronger coupling, which may impact modularity and testability.
// Results are presented in descending order to identify classes with the most dependencies.

from ClassMetrics targetClass
where exists(targetClass.getEfferentCoupling())
select targetClass, targetClass.getEfferentCoupling() as couplingMetric 
order by couplingMetric desc