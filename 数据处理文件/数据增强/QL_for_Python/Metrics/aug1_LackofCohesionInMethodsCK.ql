/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Identifies classes exhibiting low method cohesion based on Chidamber and Kemerer's metric.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 检索所有Python类并计算其方法间内聚性缺乏程度
// 使用Chidamber-Kemerer度量标准，数值越高表示内聚性越差
from ClassMetrics analyzedClass
select analyzedClass, analyzedClass.getLackOfCohesionCK() as cohesionScore order by cohesionScore desc