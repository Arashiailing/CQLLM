/**
 * @name String concatenation in loop
 * @description Detects string concatenation operations inside loops, 
 *              which can lead to quadratic performance degradation.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// 定义谓词，用于识别在循环中执行的字符串连接操作
predicate string_concat_in_loop(BinaryExpr concatExpr) {
  // 检查表达式是否为加法操作
  concatExpr.getOp() instanceof Add and
  // 查找相关的SSA变量和连接节点
  exists(SsaVariable definedVar, SsaVariable usedVar, BinaryExprNode concatNode |
    // 建立节点与表达式之间的关联
    concatNode.getNode() = concatExpr and 
    // 确定变量的定义关系
    definedVar = usedVar.getAnUltimateDefinition()
  |
    // 验证字符串连接模式：变量被定义为连接操作，并在同一操作中被使用
    definedVar.getDefinition().(DefinitionNode).getValue() = concatNode and
    usedVar.getAUse() = concatNode.getAnOperand() and
    // 确认操作数之一为字符串类型
    concatNode.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// 从所有二元表达式和包含它们的语句中查找匹配项
from BinaryExpr concatExpr, Stmt containerStmt
// 筛选条件：表达式是字符串连接操作，且包含在某个语句中
where string_concat_in_loop(concatExpr) and containerStmt.getASubExpression() = concatExpr
// 选择包含字符串连接的语句，并生成警告信息
select containerStmt, "String concatenation in a loop is quadratic in the number of iterations."