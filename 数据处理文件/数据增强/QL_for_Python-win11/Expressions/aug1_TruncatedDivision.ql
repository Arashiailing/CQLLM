/**
 * @name Integer division result may be truncated in Python 2
 * @description In Python 2, dividing two integers using '/' performs integer division,
 *              truncating the fractional part. This query identifies such operations
 *              where truncation may not be intended.
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
  // 仅在 Python 2 中相关（后续版本已实现真除法）
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftValue, Value rightValue |
    binaryNode = divisionExpr.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and // 确认是除法操作
    binaryNode.getLeft().pointsTo(leftValue, leftOperand) and
    leftValue.getClass() = ClassValue::int_() and // 左操作数是整数
    binaryNode.getRight().pointsTo(rightValue, rightOperand) and
    rightValue.getClass() = ClassValue::int_() and // 右操作数是整数
    
    // 排除整除无余数的情况
    not leftValue.(NumericValue).getIntValue() % rightValue.(NumericValue).getIntValue() = 0 and
    
    // 排除使用 `from __future__ import division` 的模块
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // 排除结果被 `int(...)` 显式包装的情况
    not exists(CallNode intCall |
      intCall = ClassValue::int_().getACall() and
      intCall.getAnArg() = binaryNode
    )
  )
select divisionExpr, 
  "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"