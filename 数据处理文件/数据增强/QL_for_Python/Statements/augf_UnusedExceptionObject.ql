/**
 * @name Unused exception object
 * @description Detects creation of exception objects that are never used.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找未使用的异常对象实例化
from Call exceptionCall
where
  // 确保调用指向一个异常类
  exists(ClassValue exceptionType |
    exceptionCall.getFunc().pointsTo(exceptionType) and
    // 验证该类是异常类型或其子类
    exceptionType.getASuperType() = ClassValue::exception()
  ) and
  // 检查该调用仅作为表达式语句存在，未被使用
  exists(ExprStmt exprStatement | 
    exprStatement.getValue() = exceptionCall
  )
select exceptionCall, "Instantiating an exception, but not raising it, has no effect."