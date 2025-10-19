/**
 * @name Outgoing class dependencies
 * @description Evaluates the count of external dependencies for individual classes.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 本查询用于分析Python代码库中每个类的外向耦合度（Efferent Coupling）
// 外向耦合度指一个类所依赖的其他类的数量，是衡量软件设计质量的重要指标
// 高外向耦合度可能表明类承担了过多职责，或与系统其他部分紧密耦合
// 查询结果按耦合度降序排列，帮助开发者优先关注需要重构的高耦合类
from ClassMetrics targetClass
select targetClass, 
       targetClass.getEfferentCoupling() as outgoingCoupling 
order by outgoingCoupling desc