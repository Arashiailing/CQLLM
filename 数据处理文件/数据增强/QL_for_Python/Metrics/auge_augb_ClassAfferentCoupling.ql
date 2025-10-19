/**
 * @name Incoming class dependencies
 * @description Measures and quantifies the number of external classes that depend on each class,
 *              providing insight into the class's impact on the codebase when changes occur.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Define afferent coupling calculation for each class and sort by the number of incoming dependencies
from ClassMetrics clsMetric, int incomingDeps
where 
  // Calculate the number of classes that depend on the current class
  incomingDeps = clsMetric.getAfferentCoupling()
select 
  clsMetric, 
  incomingDeps 
order by 
  incomingDeps desc