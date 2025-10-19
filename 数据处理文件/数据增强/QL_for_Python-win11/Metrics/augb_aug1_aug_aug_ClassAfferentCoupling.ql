/**
 * @name Incoming class dependency analysis
 * @description This query measures the afferent coupling metric for classes,
 *              indicating how many other classes rely on a particular class.
 *              Classes with higher afferent coupling are considered more critical
 *              components within the software architecture.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes and calculate their incoming dependencies
from ClassMetrics targetClass
where exists(targetClass.getAfferentCoupling())
select targetClass, 
       targetClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc