/**
 * @name Lack of Cohesion in Methods (CK)
 * @description Detects classes with poor method cohesion using the Chidamber-Kemerer metric.
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 此查询评估每个Python类的内聚性缺失程度
// 使用Chidamber-Kemerer标准，较高的值表示较低的内聚性
from ClassMetrics evaluatedClass
select evaluatedClass, evaluatedClass.getLackOfCohesionCK() as cohesionMetric order by cohesionMetric desc