/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 检测类方法的内聚性缺失程度，基于Chidamber和Kemerer提出的度量标准。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 检索每个类对象并计算其方法的内聚性缺失度量值，然后按该值降序排列
from ClassMetrics classObj
select classObj, classObj.getLackOfCohesionCK() as cohesionMetric order by cohesionMetric desc