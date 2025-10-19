/**
 * @name Python 模块外部依赖分析
 * @description 测量每个 Python 模块所依赖的外部模块数量，用于评估系统模块间的耦合程度及架构健康状况。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言支持库

// 定义模块度量数据源并计算传出耦合值
from ModuleMetrics moduleData, int outboundCoupling
where outboundCoupling = moduleData.getEfferentCoupling()

// 选择模块及其对应的传出耦合度，按数值降序排列
select moduleData, outboundCoupling 
order by outboundCoupling desc