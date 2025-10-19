/**
 * @name Python 模块传出耦合分析
 * @description 通过量化每个 Python 模块对外部模块的依赖数量，评估模块间的耦合程度和系统架构质量。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言分析所需的基础库

// 遍历所有Python模块，收集其度量指标数据
// 这些数据将用于分析模块之间的依赖关系和耦合程度
from ModuleMetrics modStats

// 获取每个模块的传出耦合度指标
// 传出耦合度表示一个模块依赖的外部模块数量
// 高耦合度值通常意味着模块独立性较差，可能影响系统的可维护性
select modStats, modStats.getEfferentCoupling() as couplingCount

// 根据传出耦合度进行降序排序
// 这样可以优先展示耦合度较高的模块，便于架构优化
order by couplingCount desc