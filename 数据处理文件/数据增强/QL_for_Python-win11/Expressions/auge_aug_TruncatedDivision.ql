/**
 * @name Result of integer division may be truncated
 * @description Identifies division operations where both operands are integers,
 *              potentially causing result truncation in Python 2.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// 检测Python 2中可能导致结果截断的整数除法操作
from BinaryExpr divOperation, ControlFlowNode leftArg, ControlFlowNode rightArg
where
  // 仅针对Python 2版本，因为Python 3及以后版本实现了真除法
  major_version() = 2 and
  exists(BinaryExprNode divNode, Value leftIntValue, Value rightIntValue |
    // 获取除法表达式节点并验证操作符为除法
    divNode = divOperation.getAFlowNode() and
    divNode.getNode().getOp() instanceof Div and
    // 验证左操作数为整数类型
    divNode.getLeft().pointsTo(leftIntValue, leftArg) and
    leftIntValue.getClass() = ClassValue::int_() and
    // 验证右操作数为整数类型
    divNode.getRight().pointsTo(rightIntValue, rightArg) and
    rightIntValue.getClass() = ClassValue::int_() and
    // 排除整除无余数的情况，因为这种情况下截断不影响结果
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    // 排除使用了`from __future__ import division`的模块，因为它们启用真除法
    not divNode.getNode().getEnclosingModule().hasFromFuture("division") and
    // 排除结果被显式转换为整数的情况，因为这可能是开发者有意为之
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = divNode
    )
  )
select divOperation, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArg, "left", rightArg, "right"