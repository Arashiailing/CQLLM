/**
 * @name Class dependency impact analysis
 * @description Measures the quantity of classes that rely on each specific class,
 *              offering visibility into a class's structural importance and potential change impact.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract classes with quantifiable incoming dependencies and calculate their dependency metrics
from ClassMetrics targetClass, int inboundDeps
where inboundDeps = targetClass.getAfferentCoupling()
select targetClass, 
       inboundDeps as dependencyCount 
order by dependencyCount desc