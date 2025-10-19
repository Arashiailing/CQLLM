/**
 * @name Result of integer division may be truncated
 * @description The arguments to a division statement may be integers, which
 *              may cause the result to be truncated in Python 2.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// 定义一个查询，用于查找可能导致结果被截断的整数除法操作
from BinaryExpr div, ControlFlowNode left, ControlFlowNode right
where
  // 仅在Python 2中相关，因为后续版本实现了真除法
  major_version() = 2 and
  exists(BinaryExprNode bin, Value lval, Value rval |
    bin = div.getAFlowNode() and // 获取除法表达式节点
    bin.getNode().getOp() instanceof Div and // 确保操作符是除法
    bin.getLeft().pointsTo(lval, left) and // 获取左操作数的值和控制流节点
    lval.getClass() = ClassValue::int_() and // 确保左操作数是整数类型
    bin.getRight().pointsTo(rval, right) and // 获取右操作数的值和控制流节点
    rval.getClass() = ClassValue::int_() and // 确保右操作数是整数类型
    // 忽略整除没有余数的情况
    not lval.(NumericValue).getIntValue() % rval.(NumericValue).getIntValue() = 0 and
    // 忽略包含`from future`导入的模块
    not bin.getNode().getEnclosingModule().hasFromFuture("division") and
    // 过滤掉用`int(...)`包装的结果
    not exists(CallNode c |
      c = ClassValue::int_().getACall() and // 检查是否存在将结果转换为整数的调用
      c.getAnArg() = bin // 确保转换的是当前除法表达式的结果
    )
  )
select div, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  left, "left", right, "right" // 选择并报告可能被截断的除法操作及其左右操作数
