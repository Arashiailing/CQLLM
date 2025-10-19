/**
 * @name Result of integer division may be truncated
 * @description Detects division operations where both arguments are integers,
 *              which may cause the result to be truncated in Python 2.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// 查找在Python 2中可能导致结果被截断的整数除法操作
from BinaryExpr truncatingDivision, ControlFlowNode leftIntOperand, ControlFlowNode rightIntOperand
where
  // 仅在Python 2中需要检查，因为后续版本实现了真除法
  major_version() = 2 and
  exists(BinaryExprNode divisionNode, Value leftIntValue, Value rightIntValue |
    // 获取除法表达式节点并确保操作符是除法
    divisionNode = truncatingDivision.getAFlowNode() and
    divisionNode.getNode().getOp() instanceof Div and
    
    // 检查左操作数是否为整数
    divisionNode.getLeft().pointsTo(leftIntValue, leftIntOperand) and
    leftIntValue.getClass() = ClassValue::int_() and
    
    // 检查右操作数是否为整数
    divisionNode.getRight().pointsTo(rightIntValue, rightIntOperand) and
    rightIntValue.getClass() = ClassValue::int_() and
    
    // 排除整除没有余数的情况，因为这种情况下截断不会影响结果
    not leftIntValue.(NumericValue).getIntValue() % rightIntValue.(NumericValue).getIntValue() = 0 and
    
    // 排除包含`from __future__ import division`的模块，因为它们使用真正的除法
    not divisionNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // 排除结果被显式转换为整数的情况，因为这可能是预期的行为
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = divisionNode
    )
  )
select truncatingDivision, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftIntOperand, "left", rightIntOperand, "right"