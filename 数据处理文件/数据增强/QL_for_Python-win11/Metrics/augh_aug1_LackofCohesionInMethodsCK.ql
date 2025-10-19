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

// 遍历所有Python类，计算其方法间的内聚性缺失度
// 基于Chidamber-Kemerer度量，分数越高表明内聚性越差
from ClassMetrics cls
select cls, cls.getLackOfCohesionCK() as cohesionScore order by cohesionScore desc