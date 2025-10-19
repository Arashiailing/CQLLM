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

// 分析每个类的外部依赖数量，衡量类对外部组件的依赖程度
// 结果按依赖数量降序排列，帮助识别可能需要重构的高耦合类
from ClassMetrics analyzedClass
select analyzedClass, 
       analyzedClass.getEfferentCoupling() as dependencyCount 
order by dependencyCount desc