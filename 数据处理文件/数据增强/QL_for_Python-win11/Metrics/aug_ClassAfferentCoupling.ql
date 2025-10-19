/**
 * @name Incoming class dependencies analysis
 * @description Calculates and displays the count of classes that have dependencies on each target class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Define the source of class metrics and extract the afferent coupling value
from ClassMetrics targetClass
where exists(targetClass.getAfferentCoupling())
select targetClass, 
       targetClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc