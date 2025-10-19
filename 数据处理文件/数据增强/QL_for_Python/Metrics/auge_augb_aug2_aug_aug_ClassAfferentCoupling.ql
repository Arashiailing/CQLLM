/**
 * @name Class Dependency Inflow Analysis
 * @description Measures the dependency inflow for each class, indicating how many other classes rely on it.
 *              This metric serves as a key indicator for modularity evaluation, where classes exhibiting
 *              high dependency inflow often represent core components that may require careful modification
 *              to avoid widespread system impacts.
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
where exists(targetClass.getAfferentCoupling())
select 
  targetClass,
  targetClass.getAfferentCoupling() as dependencyInflowCount
order by dependencyInflowCount desc