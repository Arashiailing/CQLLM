/**
 * @name Python 模块传出耦合分析
 * @description 计算每个Python模块依赖的外部模块数量，以此评估模块间的耦合关系和整体架构的健康状况。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 引入Python语言分析支持库

// 查询每个模块的传出耦合度
from ModuleMetrics moduleMetrics
select moduleMetrics, moduleMetrics.getEfferentCoupling() as couplingCount 
order by couplingCount desc // 按耦合度降序排列，高耦合度模块优先显示