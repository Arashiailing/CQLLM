/**
 * @name Class Dependency Inflow Analysis
 * @description Analyzes the dependency inflow for each class by quantifying how many other classes depend on it.
 *              This metric provides insights into software modularity, where classes with high dependency inflow
 *              typically serve as core components. Changing these core components often requires careful consideration
 *              due to their widespread impact across the system.
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