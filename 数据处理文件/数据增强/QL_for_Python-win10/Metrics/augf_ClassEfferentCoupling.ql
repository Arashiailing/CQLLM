/**
 * @name Outgoing class dependencies
 * @description Measures the count of external classes that each class references.
 * @kind treemap
 * @id py/efferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags testability
 *       modularity
 */

import python

// 检索所有类的度量数据，计算每个类的外向耦合值（依赖的外部类数量）
from ClassMetrics classMetric
select classMetric, classMetric.getEfferentCoupling() as externalDependencyCount order by externalDependencyCount desc