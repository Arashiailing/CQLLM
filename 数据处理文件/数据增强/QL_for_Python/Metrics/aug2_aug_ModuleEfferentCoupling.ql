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

// 获取所有模块的度量数据
from ModuleMetrics moduleInfo

// 计算传出耦合度并选择结果
select moduleInfo, moduleInfo.getEfferentCoupling() as couplingCount 

// 按耦合度降序排列，高耦合度模块排在前面
order by couplingCount desc