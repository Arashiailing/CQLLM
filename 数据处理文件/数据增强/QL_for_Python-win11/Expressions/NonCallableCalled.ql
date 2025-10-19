/**
 * @name Non-callable called
 * @description A call to an object which is not a callable will raise a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python  // 导入python库，用于分析Python代码
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 从Call、Value、ClassValue、Expr和AstNode中提取数据
from Call c, Value v, ClassValue t, Expr f, AstNode origin
where
  f = c.getFunc() and  // 获取调用的函数表达式
  f.pointsTo(v, origin) and  // 确定函数表达式指向的值
  t = v.getClass() and  // 获取值所属的类
  not t.isCallable() and  // 检查该类是否可调用
  not t.failedInference(_) and  // 确保类型推断没有失败
  not t.hasAttribute("__get__") and  // 检查类是否有__get__属性
  not v = Value::named("None") and  // 确保值不是None
  not use_of_not_implemented_in_raise(_, f)  // 确保没有在raise中使用NotImplemented
select c, "Call to a $@ of $@.", origin, "non-callable", t, t.toString()  // 选择并报告不可调用的对象调用
