/**
 * @name 模块传出耦合度分析
 * @description 评估每个Python模块对外部模块的依赖程度（传出耦合度）
 * @kind 树状图
 * @id py/efferent-coupling-per-file
 * @treemap.warnOn 高值警告
 * @metricType 文件
 * @metricAggregate 平均值 最大值
 * @tags 可测试性
 *       模块化
 */

import python

// 定义模块分析变量，用于评估传出耦合度
from ModuleMetrics moduleInfo

// 筛选存在传出耦合度的模块
where exists(moduleInfo.getEfferentCoupling())

// 输出每个模块及其传出耦合度（即该模块依赖的外部模块数量）
// 传出耦合度是衡量模块独立性的重要指标，值越高表示模块依赖性越强
select 
  moduleInfo, 
  moduleInfo.getEfferentCoupling() as outboundCoupling 
order by 
  outboundCoupling desc