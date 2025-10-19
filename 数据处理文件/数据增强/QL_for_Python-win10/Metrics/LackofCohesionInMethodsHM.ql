/**
 * @name Lack of Cohesion in a Class (HM)
 * @description Lack of cohesion of a class, as defined by Hitz and Montazeri.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入python模块，用于分析Python代码

// 从ClassMetrics类中选择类和其缺乏内聚性的度量值，并按降序排列
from ClassMetrics cls
select cls, cls.getLackOfCohesionHM() as n order by n desc
