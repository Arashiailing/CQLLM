/**
 * @name 非异常类型在 except 子句中使用
 * @description 检测异常处理程序中使用的非异常类型，这些类型永远无法捕获任何异常
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
from ExceptFlowNode exceptNode, 
     Value caughtType, 
     ClassValue caughtClass, 
     ControlFlowNode typeSourceNode, 
     string errorMsg
where
  // 关联异常处理节点与其处理的异常类型
  exceptNode.handledException(caughtType, caughtClass, typeSourceNode) and
  (
    // 检查情况1: 异常类型是一个类，但不是合法的异常类型
    exists(ClassValue illegalExceptionClass | 
      illegalExceptionClass = caughtType and
      not illegalExceptionClass.isLegalExceptionType() and  // 验证是否为非法异常类型
      not illegalExceptionClass.failedInference(_) and      // 确保类型推断成功
      errorMsg = "类 '" + illegalExceptionClass.getName() + "'"  // 构建错误消息
    )
    or
    // 检查情况2: 异常类型不是类值类型实例
    not caughtType instanceof ClassValue and
    errorMsg = "实例 '" + caughtClass.getName() + "'"  // 构建错误消息
  )
// 选择报告节点并生成警告信息
select exceptNode.getNode(), 
  "异常处理程序中的非异常类型 $@ 永远无法匹配抛出的异常", typeSourceNode, errorMsg