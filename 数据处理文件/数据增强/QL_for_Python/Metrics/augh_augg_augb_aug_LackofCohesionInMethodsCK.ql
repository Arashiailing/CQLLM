/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 本查询实现了Chidamber和Kemerer提出的类内聚性缺乏度量方法。
 *              该度量指标用于评估类中方法之间的关联程度，较高的数值表示较低的内聚性，
 *              这可能意味着该类承担了过多的职责，需要重构。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 获取所有已进行指标分析的类
from ClassMetrics evaluatedClass

// 计算并输出每个类的LCM值，按降序排列
// LCM值反映方法间缺乏相关性的程度，高值表示低内聚性
select evaluatedClass, evaluatedClass.getLackOfCohesionCK() as cohesionValue order by cohesionValue desc