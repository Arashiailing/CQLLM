/**
 * @name Python 模块传出耦合分析
 * @description 量化每个 Python 模块对外部模块的依赖数量，用于评估模块间的耦合程度和系统架构质量。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言支持库

// 从所有Python模块中提取度量数据，用于分析模块间的依赖关系
from ModuleMetrics moduleMetrics

// 计算传出耦合度（即模块依赖的外部模块数量）
// 较高的传出耦合度表明模块对外部依赖较多，可能影响模块的独立性和可维护性
select moduleMetrics, moduleMetrics.getEfferentCoupling() as couplingCount

// 按照传出耦合度降序排列，优先显示高耦合度模块
order by couplingCount desc