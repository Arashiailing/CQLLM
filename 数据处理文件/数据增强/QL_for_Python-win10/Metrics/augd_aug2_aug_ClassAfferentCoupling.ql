/**
 * @name Analysis of incoming class dependencies
 * @description Computes and presents the number of classes that depend on each particular class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract the target class from class metrics and obtain its afferent coupling value
from ClassMetrics targetClass, int afferentCoupling
where afferentCoupling = targetClass.getAfferentCoupling() and exists(afferentCoupling)
select targetClass, 
       afferentCoupling as dependencyCount 
order by dependencyCount desc