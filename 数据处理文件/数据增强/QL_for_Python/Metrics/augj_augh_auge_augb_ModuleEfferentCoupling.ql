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

/* 声明模块度量对象，用于计算模块对外部依赖的数量 */
from ModuleMetrics moduleMetrics

/* 过滤出具有外部依赖关系的模块 */
where exists(moduleMetrics.getEfferentCoupling())

/* 展示各模块的传出耦合度数值（反映该模块引用的外部模块总数） */
/* 传出耦合度是评估模块自主性的关键度量，数值越大表明模块对外部依赖越强 */
select 
  moduleMetrics, 
  moduleMetrics.getEfferentCoupling() as efferentCouplingValue 
order by 
  efferentCouplingValue desc