/**
 * @name Class Dependency Analysis: Inbound Coupling Metrics
 * @description Quantifies and displays how many other classes depend on each target class.
 *              This metric helps understand class importance and potential change impact.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract all classes and calculate their inbound dependency count
// Afferent coupling measures how many other classes depend on the current class
from ClassMetrics evaluatedClass, int inboundCoupling
where inboundCoupling = evaluatedClass.getAfferentCoupling()
select evaluatedClass, 
       inboundCoupling as dependencyCount 
order by dependencyCount desc