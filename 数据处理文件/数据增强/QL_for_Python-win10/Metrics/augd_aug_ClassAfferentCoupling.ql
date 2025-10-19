/**
 * @name Analysis of Incoming Class Dependencies
 * @description Computes and presents the number of classes that depend on each given class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with measurable incoming dependencies and extract coupling metrics
from ClassMetrics analyzedClass, int incomingCoupling
where incomingCoupling = analyzedClass.getAfferentCoupling()
select analyzedClass, 
       incomingCoupling as dependencyCount 
order by dependencyCount desc