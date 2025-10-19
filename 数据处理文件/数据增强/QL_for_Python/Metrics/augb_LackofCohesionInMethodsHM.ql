/**
 * @name Lack of Cohesion in a Class (HM)
 * @description Lack of cohesion of a class, as defined by Hitz and Montazeri.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入Python代码分析基础库

// 定义类度量数据源
from ClassMetrics classMetric

// 计算类内聚性缺失值并按降序排列
select 
    classMetric, 
    classMetric.getLackOfCohesionHM() as cohesionMetric 
order by 
    cohesionMetric desc