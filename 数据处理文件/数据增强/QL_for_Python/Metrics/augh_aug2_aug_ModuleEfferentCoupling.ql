/**
 * @name Python 模块传出耦合分析
 * @description 量化每个 Python 模块对外部模块的依赖数量，用于评估模块间的耦合程度和系统架构质量。
 *              传出耦合(Efferent Coupling)指一个模块依赖其他模块的数量，值越高表示该模块对外部依赖越强，
 *              可能影响模块的独立性和可测试性。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言支持库，提供Python代码分析的基础功能

// 从ModuleMetrics类中获取所有Python模块的度量数据
// ModuleMetrics是CodeQL预定义类，包含模块的各种度量信息
from ModuleMetrics moduleMetrics

// 计算并选择每个模块的传出耦合度
// 传出耦合度表示该模块依赖的外部模块数量
// 使用别名efferentCouplingValue使输出更清晰
select moduleMetrics, moduleMetrics.getEfferentCoupling() as efferentCouplingValue

// 按传出耦合度降序排列结果
// 高耦合度模块将显示在前面，便于快速识别系统中的高耦合模块
order by efferentCouplingValue desc