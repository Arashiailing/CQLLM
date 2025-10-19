/**
 * @name Incoming Dependencies per Class Analysis
 * @description Quantifies incoming dependencies (afferent coupling) for each class. 
 *              This metric counts how many other classes depend on a specific class, 
 *              identifying critical architectural components. High values indicate 
 *              classes requiring careful modification due to widespread impact potential. 
 *              Essential for architectural stability assessment and refactoring guidance.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics analyzedClass
where analyzedClass.getAfferentCoupling() > 0
select 
  analyzedClass,
  analyzedClass.getAfferentCoupling() as dependencyCount
order by 
  dependencyCount desc