/**
 * @name Python 模块传出耦合分析
 * @description 衡量每个 Python 文件对外部模块的依赖程度，帮助识别系统中耦合性较高的组件，从而评估整体架构的健壮性。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 引入Python代码分析所需的核心库

// 遍历所有Python模块的度量信息，为后续的耦合度分析做准备
from ModuleMetrics moduleStats

// 获取每个模块的传出耦合数值，表示该模块引用了多少个外部模块
// 数值越高意味着该模块与外部系统的联系越紧密，可能需要重构以提高内聚性
select moduleStats, moduleStats.getEfferentCoupling() as externalDependencyCount

// 结果按传出耦合度从高到低排序，便于快速识别需要关注的模块
order by externalDependencyCount desc