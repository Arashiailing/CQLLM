/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 计算类内方法间的内聚性缺失程度，基于Chidamber与Kemerer提出的度量标准。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 获取每个类的内聚性缺失度量值，并按照度量值从高到低排序
from ClassMetrics classObj
select classObj, classObj.getLackOfCohesionCK() as cohesionMetric order by cohesionMetric desc