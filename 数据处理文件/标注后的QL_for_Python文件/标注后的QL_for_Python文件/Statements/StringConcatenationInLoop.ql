/**
 * @name String concatenation in loop
 * @description Concatenating strings in loops has quadratic performance.
 * @kind problem
 * @tags efficiency
 *       maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @precision low
 * @id py/string-concatenation-in-loop
 */

import python

// 定义一个谓词函数，用于检测在循环中进行字符串连接的情况
predicate string_concat_in_loop(BinaryExpr b) {
  // 检查二元表达式的操作符是否为加法操作
  b.getOp() instanceof Add and
  // 存在变量d和u，以及一个二元表达式节点add，使得以下条件成立：
  exists(SsaVariable d, SsaVariable u, BinaryExprNode add |
    // add节点等于当前二元表达式b
    add.getNode() = b and 
    // d是u的最终定义
    d = u.getAnUltimateDefinition()
  |
    // d的定义值等于add，并且u的使用点是add的一个操作数，且该操作数指向字符串类
    d.getDefinition().(DefinitionNode).getValue() = add and
    u.getAUse() = add.getAnOperand() and
    add.getAnOperand().pointsTo().getClass() = ClassValue::str()
  )
}

// 从所有二元表达式b和语句s中选择满足以下条件的项：
from BinaryExpr b, Stmt s
// 其中b满足string_concat_in_loop谓词，并且s的子表达式是b
where string_concat_in_loop(b) and s.getASubExpression() = b
// 选择结果s，并输出警告信息
select s, "String concatenation in a loop is quadratic in the number of iterations."
