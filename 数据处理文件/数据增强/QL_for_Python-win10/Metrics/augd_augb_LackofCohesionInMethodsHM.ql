/**
 * @name Lack of Cohesion in a Class (HM)
 * @description Measures the lack of cohesion within classes using Hitz and Montazeri's methodology
 * @kind treemap
 * @id py/lack-of-cohesion-hitz-montazeri
 * @treemap.warnOn highValues
 * @metricType reftype
 * @metricAggregate avg max
 */

import python  // 导入Python代码分析基础库

// 获取类的度量数据并计算内聚性缺失指标
from ClassMetrics classData

// 选择类及其对应的内聚性缺失值，按降序排列结果
select 
    classData, 
    classData.getLackOfCohesionHM() as lackOfCohesion 
order by 
    lackOfCohesion desc