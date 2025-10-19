/**
 * @name 非异常类型在 except 子句中使用
 * @description 异常处理程序指定非异常类型将永远无法捕获任何异常
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python  // 导入 Python 代码分析库

// 查询异常处理程序中使用的非异常类型
from ExceptFlowNode exceptionHandlerNode, 
     Value handledExceptionType, 
     ClassValue handledExceptionClass, 
     ControlFlowNode originNode, 
     string errorMessage
where
  // 关联异常处理程序与其处理的异常类型
  exceptionHandlerNode.handledException(handledExceptionType, handledExceptionClass, originNode) and
  (
    // 检查情况1: 异常类型是一个类，但不是合法的异常类型
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = handledExceptionType and
      not invalidExceptionClass.isLegalExceptionType() and  // 验证是否为非法异常类型
      not invalidExceptionClass.failedInference(_) and      // 确保类型推断成功
      errorMessage = "类 '" + invalidExceptionClass.getName() + "'"  // 构建错误消息
    )
    or
    // 检查情况2: 异常类型不是类值类型实例
    not handledExceptionType instanceof ClassValue and
    errorMessage = "实例 '" + handledExceptionClass.getName() + "'"  // 构建错误消息
  )
// 选择报告节点并生成警告信息
select exceptionHandlerNode.getNode(), 
  "异常处理程序中的非异常类型 $@ 永远无法匹配抛出的异常", originNode, errorMessage