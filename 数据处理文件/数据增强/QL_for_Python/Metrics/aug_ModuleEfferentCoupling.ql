/**
 * @name Python 模块传出耦合分析
 * @description 分析每个 Python 模块所依赖的其他模块数量，用于评估模块间的耦合程度。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言库

from ModuleMetrics moduleMetrics // 从ModuleMetrics类中选择变量moduleMetrics
select moduleMetrics, moduleMetrics.getEfferentCoupling() as couplingCount order by couplingCount desc // 选择模块和其传出耦合度，并按降序排列