/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 类方法的缺乏内聚性，由Chidamber和Kemerer定义。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 从ClassMetrics类中选择类对象及其缺乏内聚性的度量值，并按该值降序排列
from ClassMetrics cls
select cls, cls.getLackOfCohesionCK() as n order by n desc
