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

// 引入Python分析库，提供对Python代码结构的解析和分析能力
import python

// 遍历所有模块值，并计算每个模块的直接导入数量
from ModuleValue moduleVal, int directImportCount
// 计算条件：directImportCount等于模块moduleVal通过getAnImportedModule()方法获取的所有直接导入模块的数量
where directImportCount = count(ModuleValue importedModule | importedModule = moduleVal.getAnImportedModule())
// 输出结果：模块的作用域和该模块的直接导入数量
select moduleVal.getScope(), directImportCount