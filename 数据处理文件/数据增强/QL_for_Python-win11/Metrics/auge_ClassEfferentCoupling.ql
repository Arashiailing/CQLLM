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

// 查询每个类的外向耦合数量，即该类所依赖的其他类的数量，并按依赖数量降序排列
from ClassMetrics classObj
select classObj, classObj.getEfferentCoupling() as efferentCouplingCount order by efferentCouplingCount desc