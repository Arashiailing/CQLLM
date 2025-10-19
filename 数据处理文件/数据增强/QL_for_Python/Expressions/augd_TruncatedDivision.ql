/**
 * @name Result of integer division may be truncated
 * @description In Python 2, when both operands of the division operator (/) are integers,
 *              the operation performs integer division which truncates any fractional part.
 *              This query identifies such divisions that might produce unexpected results.
 * @kind problem
 * @tags maintainability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/truncated-division
 */

import python

// 查找可能导致结果截断的整数除法表达式
from BinaryExpr divisionExpr, ControlFlowNode leftOperand, ControlFlowNode rightOperand
where
  // 仅在Python 2中需要关注，因为Python 3及更高版本默认使用真除法
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftValue, Value rightValue |
    // 确保我们处理的是除法表达式节点
    binaryNode = divisionExpr.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and
    // 检查左操作数是否为整数类型
    binaryNode.getLeft().pointsTo(leftValue, leftOperand) and
    leftValue.getClass() = ClassValue::int_() and
    // 检查右操作数是否为整数类型
    binaryNode.getRight().pointsTo(rightValue, rightOperand) and
    rightValue.getClass() = ClassValue::int_() and
    // 排除整除没有余数的情况，因为这种情况下截断不会影响结果
    not leftValue.(NumericValue).getIntValue() % rightValue.(NumericValue).getIntValue() = 0 and
    // 确保模块没有从__future__导入division，这种导入会改变除法行为
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    // 排除结果被显式转换为整数的情况，因为这种情况下截断是预期的
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryNode
    )
  )
select divisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftOperand, "left", rightOperand, "right"