/**
 * @name Class dependency impact analysis
 * @description Quantifies the afferent coupling metric for classes,
 *              which measures the number of external classes depending on a given class.
 *              Higher afferent coupling indicates greater architectural significance
 *              and potential impact from changes to the class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// Calculate incoming dependencies for classes with measurable coupling
from ClassMetrics analyzedClass, int dependencyCount
where 
  dependencyCount = analyzedClass.getAfferentCoupling() and
  exists(dependencyCount)
select 
  analyzedClass, 
  dependencyCount 
order by 
  dependencyCount desc