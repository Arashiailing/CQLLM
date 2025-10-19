/**
 * @name Import shadowed by loop variable
 * @description A loop variable shadows an import.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/import-shadowed-loop-variable
 */

// 导入Python分析库，用于代码静态分析
import python

/**
 * 判断给定变量是否遮蔽了一个导入的模块名
 * @param loopVar - 待检查的变量
 * @returns 当变量遮蔽了导入的模块名时返回true
 */
predicate shadowsImport(Variable loopVar) {
  // 查找所有可能被遮蔽的导入语句和对应的名称
  exists(Import importStmt, Name shadowedName |
    // 确保shadowedName是导入语句中的别名
    shadowedName = importStmt.getAName().getAsname() and
    // 检查变量标识符与导入名称是否相同
    shadowedName.getId() = loopVar.getId() and
    // 验证导入的作用域包含变量的作用域
    importStmt.getScope() = loopVar.getScope().getScope*()
  )
}

// 查找所有被循环变量遮蔽的导入
from Variable loopVar, Name varDefinition
// 应用过滤条件：
// 1. 变量遮蔽了导入
// 2. 名称定义了该变量
// 3. 该定义是for循环的目标
where shadowsImport(loopVar) and
      varDefinition.defines(loopVar) and
      exists(For forLoop | varDefinition = forLoop.getTarget())
// 生成警告信息，指出循环变量遮蔽了导入
select varDefinition, "Loop variable '" + loopVar.getId() + "' shadows an import."