/**
 * @name Incoming class dependencies analysis
 * @description Analyzes and quantifies the number of external classes depending on each target class. 
 *              Higher values indicate classes with more incoming dependencies, impacting modularity.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Identify classes with measurable incoming dependencies
from ClassMetrics cls
where exists(cls.getAfferentCoupling())
// Select each class and its afferent coupling count, ordered by highest dependency count first
select cls, 
       cls.getAfferentCoupling() as afferentCouplingCount 
order by afferentCouplingCount desc