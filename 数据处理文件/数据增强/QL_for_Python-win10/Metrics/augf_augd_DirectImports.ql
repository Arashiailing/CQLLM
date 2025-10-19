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

// 导入Python代码分析工具库，用于解析Python程序结构
import python

// 遍历所有模块对象，并统计每个模块的直接依赖项数量
from ModuleValue currentModule, int importCount
// 计算条件：importCount等于当前模块通过getAnImportedModule()方法获取的所有直接依赖模块的数量
where importCount = count(ModuleValue depModule | depModule = currentModule.getAnImportedModule())
// 输出结果：模块的作用域范围和该模块的直接依赖项数量
select currentModule.getScope(), importCount