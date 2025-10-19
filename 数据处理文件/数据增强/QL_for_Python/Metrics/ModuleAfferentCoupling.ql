/**
 * @name Incoming module dependencies
 * @description The number of modules that depend on a module.
 * @kind treemap
 * @id py/afferent-coupling-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       modularity
 */

import python // 导入python模块，用于分析Python代码

// 从ModuleMetrics类中选择模块m和其传入耦合度（afferent coupling）作为n，并按n降序排列
from ModuleMetrics m
select m, m.getAfferentCoupling() as n order by n desc
