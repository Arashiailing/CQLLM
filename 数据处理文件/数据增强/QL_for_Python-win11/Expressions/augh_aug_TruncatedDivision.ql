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

// 查找在Python 2中整数除法可能导致结果被截断的情况
from BinaryExpr intDivisionExpr, ControlFlowNode leftArgNode, ControlFlowNode rightArgNode
where
  // 仅在Python 2中需要检查，因为Python 3实现了真正的除法
  major_version() = 2 and
  exists(BinaryExprNode binaryNode, Value leftVal, Value rightVal |
    // 获取除法表达式的流程节点并确认操作符为除法
    binaryNode = intDivisionExpr.getAFlowNode() and
    binaryNode.getNode().getOp() instanceof Div and
    
    // 验证左右操作数均为整数类型
    binaryNode.getLeft().pointsTo(leftVal, leftArgNode) and
    binaryNode.getRight().pointsTo(rightVal, rightArgNode) and
    leftVal.getClass() = ClassValue::int_() and
    rightVal.getClass() = ClassValue::int_() and
    
    // 排除整除无余数的情况
    not leftVal.(NumericValue).getIntValue() % rightVal.(NumericValue).getIntValue() = 0 and
    
    // 排除已导入`from __future__ import division`的模块
    not binaryNode.getNode().getEnclosingModule().hasFromFuture("division") and
    
    // 排除结果被显式转换为整数的情况
    not exists(CallNode intConversionCall |
      intConversionCall = ClassValue::int_().getACall() and
      intConversionCall.getAnArg() = binaryNode
    )
  )
select intDivisionExpr, "Result of division may be truncated as its $@ and $@ arguments may both be integers.",
  leftArgNode, "left", rightArgNode, "right"