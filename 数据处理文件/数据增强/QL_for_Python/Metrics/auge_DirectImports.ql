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

// 引入Python分析库，提供代码解析和分析功能
import python

// 遍历所有模块对象，并统计其直接导入的模块数量
from ModuleValue moduleObj, int importCount
// 筛选条件：importCount等于当前模块直接导入的模块总数
where importCount = count(ModuleValue importedModule | importedModule = moduleObj.getAnImportedModule())
// 输出结果：模块的作用域范围及其直接导入的模块数量
select moduleObj.getScope(), importCount