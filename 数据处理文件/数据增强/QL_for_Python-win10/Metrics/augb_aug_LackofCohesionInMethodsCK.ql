/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 计算类方法的缺乏内聚性指标，该指标由Chidamber和Kemerer提出。
 *              该指标衡量类中方法之间缺乏相关性的程度，值越高表示内聚性越低。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 确定分析目标：获取所有已进行指标度量的类
from ClassMetrics evaluatedClass

// 评估每个类的LCM（Lack of Cohesion in Methods）值
// LCM值反映了类中方法之间的关联程度，数值越大表明内聚性越差
// 结果按LCM值降序排列，便于优先关注内聚性最弱的类
select evaluatedClass, evaluatedClass.getLackOfCohesionCK() as lcmMetric order by lcmMetric desc