/**
 * @name Pythagorean calculation with sub-optimal numerics
 * @description Calculating the length of the hypotenuse using the standard formula may lead to overflow.
 * @kind problem
 * @tags accuracy
 * @problem.severity warning
 * @sub-severity low
 * @precision medium
 * @id py/pythagorean
 */

import python
import semmle.python.dataflow.new.DataFlow
import semmle.python.ApiGraphs

// 定义一个函数，用于检测平方操作（使用幂运算符）
DataFlow::ExprNode squareOp() {
  // 检查是否存在二元表达式 e，使得 e 是结果表达式，并且 e 的操作符是幂运算且右操作数是整数字面量 "2"
  exists(BinaryExpr e | e = result.asExpr() |
    e.getOp() instanceof Pow and e.getRight().(IntegerLiteral).getN() = "2"
  )
}

// 定义一个函数，用于检测平方操作（使用乘法运算符）
DataFlow::ExprNode squareMul() {
  // 检查是否存在二元表达式 e，使得 e 是结果表达式，并且 e 的操作符是乘法且左右操作数相同
  exists(BinaryExpr e | e = result.asExpr() |
    e.getOp() instanceof Mult and e.getRight().(Name).getId() = e.getLeft().(Name).getId()
  )
}

// 定义一个函数，用于检测平方操作（无论是幂运算还是乘法运算）
DataFlow::ExprNode square() { result in [squareOp(), squareMul()] }

// 查询语句：从调用配置节点 c、二元表达式 s、左表达式节点 left 和右表达式节点 right 中选择数据
from DataFlow::CallCfgNode c, BinaryExpr s, DataFlow::ExprNode left, DataFlow::ExprNode right
where
  // 条件1：c 是 math 模块中的 sqrt 函数的调用
  c = API::moduleImport("math").getMember("sqrt").getACall() and
  // 条件2：c 的第一个参数是二元表达式 s
  c.getArg(0).asExpr() = s and
  // 条件3：s 的操作符是加法
  s.getOp() instanceof Add and
  // 条件4：左表达式节点的表达式是 s 的左操作数
  left.asExpr() = s.getLeft() and
  // 条件5：右表达式节点的表达式是 s 的右操作数
  right.asExpr() = s.getRight() and
  // 条件6：左表达式节点的本地源是平方操作
  left.getALocalSource() = square() and
  // 条件7：右表达式节点的本地源是平方操作
  right.getALocalSource() = square()
select c, "Pythagorean calculation with sub-optimal numerics."
