/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 此查询评估类中方法的内聚性缺失程度，基于Chidamber和Kemerer提出的度量标准。
 *              该指标量化类中方法之间的关联程度，较高数值表明类内聚性较差。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 获取所有已进行指标度量的类，准备评估其方法内聚性
from ClassMetrics measuredClass

// 计算每个类的LCM（Lack of Cohesion in Methods）指标
// 该指标反映类中方法之间的关联程度，数值越大表示内聚性越低
// 结果按LCM值降序排列，便于优先关注内聚性最弱的类
select measuredClass, measuredClass.getLackOfCohesionCK() as cohesionMetric order by cohesionMetric desc