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

// 识别Python 2中可能导致结果截断的整数除法操作
from BinaryExpr divisionOperation, ControlFlowNode leftArgNode, ControlFlowNode rightArgNode
where
  // 仅在Python 2中存在此问题（Python 3已实现真除法）
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftValue, Value rightValue |
    binaryNode = divisionOperation.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and // 确认是除法操作符
    binaryNode.getLeft().pointsTo(leftValue, leftArgNode) and
    leftValue.getClass() = ClassValue::int_() and // 左操作数为整数类型
    binaryNode.getRight().pointsTo(rightValue, rightArgNode) and
    rightValue.getClass() = ClassValue::int_() and // 右操作数为整数类型
    
    // 排除整除无余数的情况（不会导致截断）
    not leftValue.(NumericValue).getIntValue() % rightValue.(NumericValue).getIntValue() = 0 and
    
    // 排除已启用真除法的模块（通过future导入）
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // 排除结果被显式转换为整数的情况（表明开发者已知并接受截断）
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryNode
    )
  )
select divisionOperation, 
  "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArgNode, "left", rightArgNode, "right"