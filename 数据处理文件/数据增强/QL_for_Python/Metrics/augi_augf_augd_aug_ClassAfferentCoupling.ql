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

// Identify all classes and compute their inbound coupling count
// Inbound coupling (afferent coupling) measures the number of classes that depend on the current class
from ClassMetrics targetClass, int couplingCount
where couplingCount = targetClass.getAfferentCoupling()
select targetClass, 
       couplingCount as dependencyCount 
order by dependencyCount desc