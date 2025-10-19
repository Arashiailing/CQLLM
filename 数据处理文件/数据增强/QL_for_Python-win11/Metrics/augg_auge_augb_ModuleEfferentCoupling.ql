/**
 * @name 模块依赖耦合分析
 * @description 统计每个模块所依赖的外部模块数量（传出耦合度）
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python

// 定义模块分析对象，用于评估模块间的耦合关系
from ModuleMetrics moduleAnalysis

// 计算模块的传出耦合度，表示该模块对外部模块的依赖程度
// 较高的传出耦合度意味着模块独立性较低，可能影响可维护性和可测试性
select 
  moduleAnalysis, 
  moduleAnalysis.getEfferentCoupling() as outboundCoupling 
order by 
  outboundCoupling desc