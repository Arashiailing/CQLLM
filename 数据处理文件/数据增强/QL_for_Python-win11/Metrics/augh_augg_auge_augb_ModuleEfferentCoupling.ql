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

// 从代码库中获取所有模块指标，用于分析模块间的依赖关系
from ModuleMetrics moduleUnderAnalysis

// 提取每个模块的传出耦合度，表示该模块依赖的外部模块数量
// 较高的传出耦合度可能表明模块设计不够独立，影响可测试性和可维护性
select 
  moduleUnderAnalysis, 
  moduleUnderAnalysis.getEfferentCoupling() as externalDependencyCount 

// 按传出耦合度降序排列，优先展示高耦合模块
order by 
  externalDependencyCount desc