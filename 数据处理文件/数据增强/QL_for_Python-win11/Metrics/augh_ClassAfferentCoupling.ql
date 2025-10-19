/**
 * @name Incoming class dependencies
 * @description The number of classes that depend on a class.
 * @kind treemap
 * @id py/afferent-coupling-per-class
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 * @tags changeability
 *       modularity
 */

import python

// 检索每个类的传入耦合度（即依赖于该类的其他类的数量），并按耦合度从高到低排序
from ClassMetrics classObj
select classObj, classObj.getAfferentCoupling() as couplingCount order by couplingCount desc