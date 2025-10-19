/**
 * @name Lack of Cohesion in a Class (HM)
 * @description This query measures the lack of cohesion within classes using the methodology
 *              defined by Hitz and Montazeri. Higher values indicate poorer class design
 *              where methods do not strongly relate to shared instance variables.
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入Python代码分析基础库

// 获取类度量数据源，用于计算内聚性指标
from ClassMetrics clsData

// 检索每个类及其对应的Hitz-Montazeri内聚性缺失值
// 内聚性缺失值越高，表示类设计越不合理
select 
    clsData, 
    clsData.getLackOfCohesionHM() as lcmScore 
order by 
    lcmScore desc