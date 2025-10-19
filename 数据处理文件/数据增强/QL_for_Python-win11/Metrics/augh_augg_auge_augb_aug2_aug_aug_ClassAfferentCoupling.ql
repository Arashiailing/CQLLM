/**
 * @name Class Dependency Inflow Analysis
 * @description This analysis identifies and quantifies the afferent coupling (incoming dependencies) 
 *              for each class in the codebase. Afferent coupling is a fundamental architectural metric 
 *              that counts how many other classes depend on a specific class. Classes with high 
 *              afferent coupling values are critical system components that require careful handling 
 *              during modifications, as changes can have widespread impact. This metric is essential 
 *              for architectural analysis, helping identify stable components that should change 
 *              infrequently and guiding refactoring efforts to improve system maintainability.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

from ClassMetrics targetClass
where targetClass.getAfferentCoupling() > 0
select 
  targetClass,
  targetClass.getAfferentCoupling() as inflowCount
order by 
  inflowCount desc