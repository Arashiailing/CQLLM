/**
 * @name Incoming class dependencies analysis
 * @description Calculates and displays the count of classes that have dependencies on each target class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// 评估类的传入耦合：确定并计算每个目标类被其他类依赖的数量
from ClassMetrics analyzedClass, int couplingValue
where couplingValue = analyzedClass.getAfferentCoupling() and exists(couplingValue)
select analyzedClass, 
       couplingValue as dependencyCount 
order by dependencyCount desc