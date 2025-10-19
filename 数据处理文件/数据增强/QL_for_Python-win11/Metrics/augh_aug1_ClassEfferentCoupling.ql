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

// 计算每个类的外向耦合数量，即该类依赖的其他类的数量
// 高外向耦合表明类之间的依赖关系复杂，可能影响代码的可维护性和可测试性
// 结果按照耦合数量从高到低排序，以识别需要重构的高度耦合类
from ClassMetrics analyzedClass
select analyzedClass, analyzedClass.getEfferentCoupling() as dependencyCount 
order by dependencyCount desc