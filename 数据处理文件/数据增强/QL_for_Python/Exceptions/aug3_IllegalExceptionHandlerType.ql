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

// 从异常流节点、类型值、类值、控制流节点和描述字符串中选择变量
from ExceptFlowNode exceptFlowNode, 
     Value exceptionType, 
     ClassValue exceptionClass, 
     ControlFlowNode sourceNode, 
     string description
where
  // 条件：异常处理器处理了来自 sourceNode 的 exceptionType 类型异常
  exceptFlowNode.handledException(exceptionType, exceptionClass, sourceNode) and
  (
    // 情况1：存在非异常类类型
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = exceptionType and
      not nonExceptionClass.isLegalExceptionType() and  // 非法异常类型
      not nonExceptionClass.failedInference(_) and      // 无推断失败
      description = "类 '" + nonExceptionClass.getName() + "'"  // 设置描述信息
    )
    or
    // 情况2：非类值类型实例
    not exceptionType instanceof ClassValue and
    description = "实例 '" + exceptionClass.getName() + "'"  // 设置描述信息
  )
select exceptFlowNode.getNode(),  // 选择报告节点
  "异常处理程序中的非异常类型 $@ 永远无法匹配抛出的异常", sourceNode, description  // 生成报告信息