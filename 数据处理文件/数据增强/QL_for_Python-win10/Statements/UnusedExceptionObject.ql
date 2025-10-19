/**
 * @name Unused exception object
 * @description An exception object is created, but is not used.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 定义查询语句，查找未使用的异常对象
from Call call, ClassValue ex
where
  // 检查调用的函数是否指向一个异常对象
  call.getFunc().pointsTo(ex) and
  // 检查该对象是否是异常类的实例或子类
  ex.getASuperType() = ClassValue::exception() and
  // 确认存在一个表达式语句，其值等于调用
  exists(ExprStmt s | s.getValue() = call)
select call, "Instantiating an exception, but not raising it, has no effect."  // 选择符合条件的调用，并输出警告信息
