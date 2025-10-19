/**
 * @name Non-exception in 'except' clause
 * @description An exception handler specifying a non-exception type will never handle any exception.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python  // 导入python库，用于分析Python代码

// 定义一个查询，从ExceptFlowNode、Value、ClassValue、ControlFlowNode和string类型的变量中进行选择
from ExceptFlowNode ex, Value t, ClassValue c, ControlFlowNode origin, string what
where
  // 条件1：ex处理了类型为t的异常，并且该异常来源于origin节点
  ex.handledException(t, c, origin) and
  (
    // 子条件1：存在一个ClassValue类型的x，使得x等于t，并且x不是一个合法的异常类型，且没有失败的推断
    exists(ClassValue x | x = t |
      not x.isLegalExceptionType() and  // x不是一个合法的异常类型
      not x.failedInference(_) and  // 没有失败的推断
      what = "class '" + x.getName() + "'"  // 设置what字符串为异常类的名称
    )
    or
    // 子条件2：t不是ClassValue的实例，并且设置what字符串为c的名称
    not t instanceof ClassValue and
    what = "instance of '" + c.getName() + "'"
  )
select ex.getNode(),  // 选择要报告的节点
  "Non-exception $@ in exception handler which will never match raised exception.", origin, what  // 生成报告信息，包括异常处理器中的非异常类型、来源节点和异常类型描述
