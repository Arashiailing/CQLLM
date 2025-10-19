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

// 定义数据源：从ClassMetrics获取所有已测量的类
from ClassMetrics measuredClass

// 计算每个类的缺乏内聚性值，并按降序排列
// 高值表示类的方法之间缺乏相关性，可能需要重构以提高内聚性
select measuredClass, measuredClass.getLackOfCohesionCK() as cohesionValue order by cohesionValue desc