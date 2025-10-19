/**
 * @name Incoming class dependency analysis
 * @description Evaluates afferent coupling for classes - quantifying how many other 
 *              classes depend on a particular class. Elevated values signify components
 *              that are more critical within the software architecture.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes that have dependencies from other classes
from ClassMetrics targetClass
where targetClass.getAfferentCoupling() > 0
select targetClass, 
       targetClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc