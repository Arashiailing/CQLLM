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
 * 此谓词识别Python模块中存在的自导入情况，即一个模块直接或间接导入自身。
 * 自导入通常是不必要的代码模式，可能导致循环依赖和代码维护困难。
 * 
 * 参数:
 * - importDeclaration: 被分析的导入语句节点
 * - targetModule: 被导入的模块值对象
 */
predicate selfImportDetected(ImportingStmt importDeclaration, ModuleValue targetModule) {
  // 验证导入语句所属的模块与被导入模块的作用域相同
  // 这是自导入检测的核心条件
  importDeclaration.getEnclosingModule() = targetModule.getScope() and
  // 通过聚合操作确定最匹配的模块值
  // 优先选择最长匹配名称的模块以正确处理相对导入情况
  targetModule = 
    max(string moduleName, ModuleValue potentialModule |
      // 获取导入语句中引用的模块名称
      moduleName = importDeclaration.getAnImportedModuleName() and
      // 检查潜在模块是否以该名称被导入
      potentialModule.importedAs(moduleName)
    |
      // 按模块名称长度降序排列，确保最长匹配优先
      potentialModule order by moduleName.length() desc
    )
}

// 主查询：识别所有自导入模块实例
// 
// 此查询遍历所有导入语句，通过selfImportDetected谓词筛选出
// 满足自导入条件的语句，并生成相应的警告信息。
from ImportingStmt importDeclaration, ModuleValue targetModule
where selfImportDetected(importDeclaration, targetModule)
select importDeclaration, "The module '" + targetModule.getName() + "' imports itself."