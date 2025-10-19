/**
 * @name Module imports itself
 * @description A module imports itself
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/import-own-module
 */

import python

/**
 * 检测模块自导入行为的谓词函数
 * 
 * 此谓词用于识别Python模块中的自导入现象，即模块直接或间接地导入自身。
 * 自导入模式通常是不必要的，可能导致循环依赖问题并增加代码维护难度。
 * 
 * 参数:
 * - importNode: 待检查的导入语句节点
 * - targetModule: 被导入的模块值对象
 */
predicate findSelfImport(ImportingStmt importNode, ModuleValue targetModule) {
  // 验证导入语句所属模块与被导入模块的作用域相同
  // 这是自导入检测的核心条件
  targetModule.getScope() = importNode.getEnclosingModule() and
  // 通过聚合操作确定最匹配的模块值
  // 优先选择最长匹配名称的模块，以正确处理相对导入情况
  targetModule = 
    max(string moduleName, ModuleValue moduleCandidate |
      // 获取导入语句中引用的模块名称
      moduleName = importNode.getAnImportedModuleName() and
      // 确认候选模块是否以该名称被导入
      moduleCandidate.importedAs(moduleName)
    |
      // 按模块名称长度降序排序，确保最长匹配优先
      moduleCandidate order by moduleName.length() desc
    )
}

// 主查询：识别所有自导入模块实例
// 
// 本查询遍历所有导入语句，通过findSelfImport谓词筛选出
// 符合自导入条件的语句，并生成相应的警告信息。
from ImportingStmt importNode, ModuleValue targetModule
where findSelfImport(importNode, targetModule)
select importNode, "The module '" + targetModule.getName() + "' imports itself."