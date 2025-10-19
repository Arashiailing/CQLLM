/**
 * @name Result of integer division may be truncated
 * @description In Python 2, when both operands of a division operation are integers,
 *              the result is truncated to an integer. This can lead to unexpected results
 *              if the developer intended to perform floating-point division.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// 查找可能导致结果被截断的整数除法操作
from BinaryExpr divisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // 仅在Python 2中相关，因为Python 3及以后版本默认实现真除法
  major_version() = 2 and
  exists(BinaryExprNode divisionNode, Value leftValue, Value rightValue |
    divisionNode = divisionExpr.getAFlowNode() and // 获取除法表达式的控制流节点
    divisionNode.getNode().getOp() instanceof Div and // 确保操作符是除法
    // 检查左操作数是否为整数
    divisionNode.getLeft().pointsTo(leftValue, leftOperand) and
    leftValue.getClass() = ClassValue::int_() and
    // 检查右操作数是否为整数
    divisionNode.getRight().pointsTo(rightValue, rightOperand) and
    rightValue.getClass() = ClassValue::int_() and
    // 忽略整除没有余数的情况，因为这种情况下结果不会被截断
    not leftValue.(NumericValue).getIntValue() % rightValue.(NumericValue).getIntValue() = 0 and
    // 忽略包含`from __future__ import division`的模块，因为这会改变除法行为
    not divisionNode.getNode().getEnclosingModule().hasFromFuture("division") and
    // 过滤掉用`int(...)`包装的结果，因为这是有意为之的截断
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = divisionNode
    )
  )
select divisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"