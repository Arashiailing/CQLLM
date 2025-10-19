/**
 * @name Incoming class dependencies
 * @description Count of classes that have dependencies on a given class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// 查询每个类的传入耦合度（即依赖于该类的其他类数量），
// 并按照耦合度从高到低排序
from ClassMetrics classMetric
select classMetric, classMetric.getAfferentCoupling() as couplingCount order by couplingCount desc