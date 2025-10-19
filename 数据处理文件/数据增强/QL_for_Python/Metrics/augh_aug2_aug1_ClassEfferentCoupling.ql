/**
 * @name Outgoing class dependencies
 * @description Calculates the number of external dependencies for each class.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 评估每个类的传出耦合度，即该类依赖的外部类或模块的数量
// 传出耦合度高表示类与外部组件紧密耦合，可能影响代码的可维护性和可测试性
// 结果按传出耦合度降序排列，便于识别需要重构的高耦合类
from ClassMetrics targetClass
select targetClass, 
       targetClass.getEfferentCoupling() as outgoingCoupling 
order by outgoingCoupling desc