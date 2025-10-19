/**
 * @name Direct imports per file
 * @description The number of modules directly imported by this file.
 * @kind treemap
 * @id py/direct-imports-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg max
 * @tags modularity
 *       maintainability
 */

// 导入Python库，用于处理Python代码的解析和分析
import python

// 从ModuleValue类中获取模块m，并计算其直接导入的模块数量n
from ModuleValue m, int n
// 条件：n等于通过调用m.getAnImportedModule()方法获取的直接导入模块的数量
where n = count(ModuleValue imp | imp = m.getAnImportedModule())
// 选择模块m的作用域和直接导入模块的数量n作为查询结果
select m.getScope(), n
