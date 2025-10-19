/**
 * @name Outgoing class dependencies
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

// 查询每个类的外向耦合数量，即该类依赖的其他类的数量
// 结果按照耦合数量从高到低排序，以识别高度耦合的类
from ClassMetrics targetClass
select targetClass, targetClass.getEfferentCoupling() as couplingCount order by couplingCount desc