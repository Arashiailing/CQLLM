/**
 * @name Analysis of incoming class dependencies
 * @description This query identifies and counts the number of classes that depend on each target class,
 *              providing insight into the afferent coupling metric for modularity assessment.
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
from ClassMetrics measuredClass
where exists(measuredClass.getAfferentCoupling())
select measuredClass, 
       measuredClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc