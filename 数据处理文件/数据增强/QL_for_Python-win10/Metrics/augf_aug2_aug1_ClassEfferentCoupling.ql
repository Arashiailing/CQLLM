/**
 * @name Outgoing class dependencies
 * @description Measures the count of external dependencies for each class to evaluate coupling.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 此查询评估每个类的外部依赖数量，用于量化类的耦合程度
// 依赖数量较高的类可能表明设计上存在紧密耦合，需要考虑重构
// 结果按依赖数量降序排列，便于识别最需要关注的类
from ClassMetrics evaluatedClass
where exists(evaluatedClass.getEfferentCoupling())
select evaluatedClass, 
       evaluatedClass.getEfferentCoupling() as outgoingCouplingCount 
order by outgoingCouplingCount desc