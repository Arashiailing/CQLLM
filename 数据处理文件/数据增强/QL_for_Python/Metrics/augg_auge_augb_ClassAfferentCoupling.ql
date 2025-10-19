/**
 * @name Incoming class dependencies
 * @description Quantifies external dependencies on each class to assess 
 *              potential impact of changes across the codebase
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Calculate afferent coupling for each class and rank by dependency count
from ClassMetrics classMetrics, int dependencyCount
where 
  // Determine number of classes depending on the current class
  dependencyCount = classMetrics.getAfferentCoupling()
select 
  classMetrics, 
  dependencyCount 
order by 
  dependencyCount desc