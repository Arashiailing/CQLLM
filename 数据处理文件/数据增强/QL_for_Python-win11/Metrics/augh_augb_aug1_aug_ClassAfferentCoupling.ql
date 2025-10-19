/**
 * @name Class Dependency Inflow Analysis
 * @description Quantifies the number of external classes that depend on each subject class.
 *              Higher values indicate classes with greater incoming dependencies, which impacts
 *              modularity and increases the risk of changes causing ripple effects throughout the codebase.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Analyze classes and their inbound dependency metrics
from ClassMetrics subjectClass, int dependencyCount
where 
  // Calculate the afferent coupling (incoming dependencies) for each class
  dependencyCount = subjectClass.getAfferentCoupling() and
  // Ensure the dependency count is measurable (not null)
  exists(dependencyCount)
  
// Select each class with its corresponding dependency count,
// ordered from highest to lowest to identify highly coupled components
select subjectClass, 
       dependencyCount 
order by dependencyCount desc