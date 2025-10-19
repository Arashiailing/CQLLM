/**
 * @name 输出模块依赖关系
 * @description 此模块所依赖的模块数量。
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python // 导入Python语言库

from ModuleMetrics m // 从ModuleMetrics类中选择变量m
select m, m.getEfferentCoupling() as n order by n desc // 选择m和m的传出耦合度，并按降序排列
