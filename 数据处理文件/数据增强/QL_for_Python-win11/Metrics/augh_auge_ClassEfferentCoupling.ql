/**
 * @name Outgoing class dependencies
 * @description The number of classes that this class depends upon.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 计算每个类的外向耦合值，即该类引用的其他类的数量，结果按耦合度降序排列
from ClassMetrics cls
select cls, cls.getEfferentCoupling() as couplingValue order by couplingValue desc