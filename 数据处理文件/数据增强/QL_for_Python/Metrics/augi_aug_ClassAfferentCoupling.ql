/**
 * @name Class dependency incoming analysis
 * @description Analyzes and presents the number of classes that depend on each analyzed class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract class metrics focusing on afferent coupling
from ClassMetrics analyzedClass
where exists(analyzedClass.getAfferentCoupling())
select analyzedClass, 
       analyzedClass.getAfferentCoupling() as incomingDependenciesCount 
order by incomingDependenciesCount desc