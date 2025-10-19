/**
 * @name Incoming class dependency analysis
 * @description Measures afferent coupling for classes - the number of other classes 
 *              that depend on a specific class. Higher values indicate more critical
 *              components in the software architecture.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Analyze classes with existing dependency relationships
from ClassMetrics analyzedClass
where analyzedClass.getAfferentCoupling() > 0
select analyzedClass, 
       analyzedClass.getAfferentCoupling() as dependencyCount 
order by dependencyCount desc