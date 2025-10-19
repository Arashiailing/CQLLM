/**
 * @name Class Dependency Inflow Analysis
 * @description Computes the afferent coupling metric for classes, which quantifies
 *              the number of external classes that depend on a given class. Classes
 *              with elevated afferent coupling values represent pivotal components
 *              in the software architecture, requiring careful consideration during
 *              maintenance and refactoring activities.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract classes with measurable incoming dependencies and compute their coupling metrics
from ClassMetrics subjectClass
where exists(subjectClass.getAfferentCoupling())
select subjectClass, 
       subjectClass.getAfferentCoupling() as incomingCoupling 
order by incomingCoupling desc