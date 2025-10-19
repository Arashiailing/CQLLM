/**
 * @name 模块传出耦合度分析
 * @description 量化每个模块对外部模块的依赖程度，通过计算传出耦合度来评估模块独立性
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python

// 定义模块分析对象，用于评估模块间的依赖关系
from ModuleMetrics coupledModule

// 提取每个模块的传出耦合度，该指标反映了模块对其他模块的依赖程度
// 高耦合度值表明模块独立性较差，可能影响可维护性和可测试性
select 
  coupledModule, 
  coupledModule.getEfferentCoupling() as externalDependencyCount 
order by 
  externalDependencyCount desc