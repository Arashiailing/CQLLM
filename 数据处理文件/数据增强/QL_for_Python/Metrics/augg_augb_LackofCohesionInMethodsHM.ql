/**
 * @name Class Cohesion Deficiency Metric (Hitz-Montazeri)
 * @description Measures the lack of cohesion within classes using the Hitz and Montazeri method.
 *              Higher values indicate lower cohesion, suggesting potential refactoring opportunities.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入Python代码分析基础库

// 从类度量数据源中获取信息
from ClassMetrics clsMetric

// 检索类内聚性缺失指标并按降序排列，值越高表示内聚性越差
select 
    clsMetric, 
    clsMetric.getLackOfCohesionHM() as cohesionValue 
order by 
    cohesionValue desc