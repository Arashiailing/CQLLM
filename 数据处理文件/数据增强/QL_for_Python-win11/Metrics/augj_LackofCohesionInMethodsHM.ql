/**
 * @name Class Cohesion Deficiency (Hitz-Montazeri Metric)
 * @description Quantifies class cohesion deficiency using Hitz and Montazeri's methodology.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入Python模块以支持代码分析

// 从类度量集合中提取目标类及其内聚性缺陷值
from ClassMetrics classMetric
// 按内聚性缺陷值降序排列结果，缺陷值越大表示内聚性越低
select classMetric, 
       classMetric.getLackOfCohesionHM() as cohesionDeficit 
order by cohesionDeficit desc