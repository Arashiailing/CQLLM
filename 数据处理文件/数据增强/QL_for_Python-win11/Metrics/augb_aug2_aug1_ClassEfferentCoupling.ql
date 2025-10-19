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

// 评估每个类的外部依赖数量，测量类对外部组件的耦合度
// 结果按照依赖数量从高到低排序，便于识别可能需要重构的高耦合类
from ClassMetrics examinedClass
select examinedClass, 
       examinedClass.getEfferentCoupling() as externalDependencyCount 
order by externalDependencyCount desc