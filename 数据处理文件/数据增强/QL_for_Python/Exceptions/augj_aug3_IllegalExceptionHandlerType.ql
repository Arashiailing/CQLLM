/**
 * @name 非异常类型在 except 子句中使用
 * @description 检测 Python 代码中异常处理程序使用了非异常类型的情况，
 *              这种异常处理程序永远无法捕获任何实际抛出的异常
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

// 定义查询变量：异常流节点、异常类型值、异常类值、异常源节点和错误消息
from ExceptFlowNode exceptionFlowNode, 
     Value exceptionValueType, 
     ClassValue exceptionClassValue, 
     ControlFlowNode exceptionSourceNode, 
     string errorMessage
where
  // 检查异常处理器是否处理了指定源节点的异常类型
  exceptionFlowNode.handledException(exceptionValueType, exceptionClassValue, exceptionSourceNode) and
  (
    // 情况一：处理非法异常类类型
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = exceptionValueType and
      not invalidExceptionClass.isLegalExceptionType() and  // 确认不是合法异常类型
      not invalidExceptionClass.failedInference(_) and      // 确认类型推断未失败
      errorMessage = "类 '" + invalidExceptionClass.getName() + "'"  // 构造错误消息
    )
    or
    // 情况二：处理非类值类型的实例
    not exceptionValueType instanceof ClassValue and
    errorMessage = "实例 '" + exceptionClassValue.getName() + "'"  // 构造错误消息
  )
select exceptionFlowNode.getNode(),  // 选择报告节点
  "异常处理程序中的非异常类型 $@ 永远无法匹配抛出的异常", exceptionSourceNode, errorMessage  // 生成报告信息