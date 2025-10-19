/**
 * @name 输出模块依赖关系
 * @description 计算每个模块所依赖的其他模块数量（传出耦合度）
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python

from ModuleMetrics moduleMetric // 使用更具描述性的变量名
select 
  moduleMetric, 
  moduleMetric.getEfferentCoupling() as couplingCount 
order by 
  couplingCount desc // 按耦合度降序排列