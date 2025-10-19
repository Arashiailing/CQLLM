/**
 * @name Class Inbound Dependency Analysis
 * @description Measures the inbound dependency count for each class, indicating how many other classes
 *              rely on it. This metric serves as a key indicator for modularity evaluation, where classes
 *              with elevated inbound dependencies typically represent core components that might require
 *              careful modification to prevent widespread system impacts.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics examinedClass, int dependencyCount
where dependencyCount = examinedClass.getAfferentCoupling() and
      exists(dependencyCount)
select 
  examinedClass,
  dependencyCount
order by dependencyCount desc