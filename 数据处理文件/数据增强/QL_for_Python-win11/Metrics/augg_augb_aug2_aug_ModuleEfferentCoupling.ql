/**
 * @name Python 模块传出耦合分析
 * @description 评估每个 Python 文件对外部模块的依赖程度，通过量化传出耦合来识别高耦合模块，有助于改善系统架构和模块化设计。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 引入Python语言分析支持

// 获取所有Python模块的度量信息，用于评估模块间的耦合关系
from ModuleMetrics pyModMetric

// 计算模块的传出耦合值（即该模块依赖的外部模块数量）
// 高传出耦合值表示模块对外部依赖性强，可能降低模块的独立性和可测试性
select pyModMetric, pyModMetric.getEfferentCoupling() as externalDepCount

// 按传出耦合值降序排序，突出显示高耦合模块
order by externalDepCount desc