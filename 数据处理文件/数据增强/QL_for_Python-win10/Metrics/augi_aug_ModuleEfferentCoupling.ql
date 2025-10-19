/**
 * @name Python 模块传出耦合分析
 * @description 此查询用于量化每个 Python 模块的传出耦合度，即该模块所依赖的其他模块数量。
 *              传出耦合度高可能表明模块职责过多，降低了代码的可维护性和可测试性。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言分析库

// 从ModuleMetrics类中获取每个模块的分析对象
from ModuleMetrics moduleAnalysis

// 选择模块及其传出耦合度，按耦合度降序排列
select moduleAnalysis, 
       moduleAnalysis.getEfferentCoupling() as dependencyCount 
order by dependencyCount desc