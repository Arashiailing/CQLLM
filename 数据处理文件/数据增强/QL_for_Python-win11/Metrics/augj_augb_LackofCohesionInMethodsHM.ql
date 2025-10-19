/**
 * @name Lack of Cohesion in a Class (HM)
 * @description Measures the lack of cohesion within classes using the Hitz-Montazeri method.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入Python代码分析基础库

// 获取类度量数据源并计算内聚性缺失指标
from ClassMetrics clsMetric

// 按内聚性缺失值降序排列输出结果
select 
    clsMetric, 
    clsMetric.getLackOfCohesionHM() as lcmValue 
order by 
    lcmValue desc