/**
 * @name Illegal raise
 * @description Raising a non-exception object or type will result in a TypeError being raised instead.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision very-high
 * @id py/illegal-raise
 */

// 导入Python库，用于处理Python代码的查询
import python
// 导入Raising库，用于处理异常抛出相关的查询
import Raising
// 导入Exceptions.NotImplemented库，用于处理未实现异常相关的查询
import Exceptions.NotImplemented

// 从Raise类中引入r变量，从ClassValue类中引入t变量
from Raise r, ClassValue t
// 设置查询条件：
where
  // 检查r的类型或类型信息是否与t匹配
  type_or_typeof(r, t, _) and
  // 检查t是否不是一个合法的异常类型
  not t.isLegalExceptionType() and
  // 检查t的类型推断是否失败
  not t.failedInference(_) and
  // 检查r是否不是使用了NotImplemented异常
  not use_of_not_implemented_in_raise(r, _)
// 选择符合条件的r和生成的错误信息字符串
select r,
  "Illegal class '" + t.getName() + "' raised; will result in a TypeError being raised instead."
