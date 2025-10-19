/**
 * @name Class Efferent Coupling Analysis
 * @description Measures the count of external classes that a given class relies on.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 计算每个类的出向耦合度，即该类依赖的外部类的数量
// 出向耦合度高表示该类依赖许多其他类，可能影响其可测试性和模块化
from ClassMetrics cls
select cls, 
       cls.getEfferentCoupling() as couplingMetric 
order by couplingMetric desc