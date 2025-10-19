/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 此查询实现Chidamber和Kemerer提出的类内聚性缺乏度量。
 *              该指标量化类中方法间的关联程度，数值越高表示内聚性越低，
 *              可能表明类承担了过多职责。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 获取所有已进行指标分析的类并计算其LCM值
// LCM值反映方法间缺乏相关性的程度，高值表示低内聚性
// 结果按LCM值降序排列，便于识别最需要重构的类
from ClassMetrics measuredClass
select measuredClass, measuredClass.getLackOfCohesionCK() as cohesionValue order by cohesionValue desc