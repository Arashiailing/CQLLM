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

// 导入Python语言分析支持库，提供代码解析和语义分析功能
import python

// 查询目标：分析每个Python模块文件的直接导入依赖数量
from ModuleValue moduleEntity, int directImportCount
// 筛选条件：计算当前模块直接导入的所有模块数量
where 
  directImportCount = count(ModuleValue directlyImportedModule | 
    moduleEntity.getAnImportedModule() = directlyImportedModule)
// 输出格式：模块的作用域范围及其对应的直接导入模块数量
select moduleEntity.getScope(), directImportCount