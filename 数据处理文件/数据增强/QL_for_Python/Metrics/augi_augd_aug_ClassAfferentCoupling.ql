/**
 * @name Class Dependency Analysis
 * @description Quantifies and displays the count of classes that have dependencies on each target class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Extract classes with quantifiable incoming dependencies and calculate their coupling metrics
from ClassMetrics targetClass, int afferentDependencies
where afferentDependencies = targetClass.getAfferentCoupling()
select targetClass, 
       afferentDependencies as couplingMetric 
order by couplingMetric desc