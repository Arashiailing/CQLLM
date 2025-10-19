/**
 * @name Python 模块外部依赖分析
 * @description 统计每个Python模块所依赖的外部模块数量，用于评估模块间的耦合度。
 * @kind 树状图
 * @id py/module-external-dependencies
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 引入Python语言分析库

// 定义变量表示模块度量数据
from ModuleMetrics moduleData 
// 计算每个模块的传出耦合度（即依赖的外部模块数量）
// 并按耦合度从高到低排序
select moduleData, moduleData.getEfferentCoupling() as couplingCount order by couplingCount desc