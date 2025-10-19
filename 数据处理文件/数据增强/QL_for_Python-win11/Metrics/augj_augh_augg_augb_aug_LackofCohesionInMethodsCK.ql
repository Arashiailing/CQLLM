/**
 * @name Lack of Cohesion in Methods (CK)
 * @description 该查询实现了Chidamber和Kemerer定义的类内聚性缺乏度量。
 *              此指标用于衡量类内方法之间的相关性程度，数值越高表示内聚性越低，
 *              表明该类可能承担了过多职责，需要考虑重构。
 * @kind treemap
 * @id py/lack-of-cohesion-chidamber-kemerer
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python

// 查找所有已进行指标分析的类
from ClassMetrics analyzedClass

// 计算每个类的内聚性缺乏度量值(LCM)
// LCM值表示方法间缺乏相关性的程度，数值越高表明内聚性越低
select analyzedClass, 
       analyzedClass.getLackOfCohesionCK() as cohesionValue 
order by cohesionValue desc