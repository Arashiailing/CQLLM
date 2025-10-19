/**
 * @name 输出模块依赖关系
 * @description 计算每个模块所依赖的其他模块数量（传出耦合度）
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python

// 定义模块分析变量，用于计算传出耦合度
from ModuleMetrics moduleDependency

// 计算每个模块的传出耦合度（即该模块依赖的其他模块数量）
// 传出耦合度是衡量模块独立性的重要指标，值越高表示模块依赖性越强
select 
  moduleDependency, 
  moduleDependency.getEfferentCoupling() as dependencyCount 
order by 
  dependencyCount desc