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
 * 识别模块自导入行为的谓词函数
 * 
 * 本谓词用于检测Python模块中存在的自导入现象，即模块直接或间接导入自身。
 * 这种模式通常是不必要的，可能引发循环依赖问题并增加维护复杂度。
 * 
 * 参数:
 * - importStmt: 待分析的导入语句节点
 * - importedModule: 被导入的模块值对象
 */
predicate detectSelfImport(ImportingStmt importStmt, ModuleValue importedModule) {
  // 确保导入语句所属模块与被导入模块的作用域一致
  // 这是自导入检测的核心判断条件
  importStmt.getEnclosingModule() = importedModule.getScope() and
  // 通过聚合操作确定最匹配的模块值
  // 优先选择最长匹配名称的模块以正确处理相对导入场景
  importedModule = 
    max(string importedName, ModuleValue candidateModule |
      // 获取导入语句中引用的模块名称
      importedName = importStmt.getAnImportedModuleName() and
      // 验证候选模块是否以该名称被导入
      candidateModule.importedAs(importedName)
    |
      // 按模块名称长度降序排列，确保最长匹配优先
      candidateModule order by importedName.length() desc
    )
}

// 主查询：识别所有自导入模块实例
// 
// 此查询遍历所有导入语句，通过detectSelfImport谓词筛选出
// 满足自导入条件的语句，并生成相应的警告信息。
from ImportingStmt importStmt, ModuleValue importedModule
where detectSelfImport(importStmt, importedModule)
select importStmt, "The module '" + importedModule.getName() + "' imports itself."