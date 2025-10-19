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

// 此查询用于检测Python类中方法内聚性缺乏的情况
// 内聚性是衡量类中方法之间相关程度的指标，低内聚性表明类设计可能存在问题
// Chidamber-Kemerer度量标准通过计算类中方法共享实例变量的程度来衡量内聚性
// 分数越高表示类的方法之间内聚性越差，可能需要重构
from ClassMetrics targetClass
select targetClass, targetClass.getLackOfCohesionCK() as cohesionScore order by cohesionScore desc