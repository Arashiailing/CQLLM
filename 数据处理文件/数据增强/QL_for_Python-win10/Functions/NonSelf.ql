/**
 * @name First parameter of a method is not named 'self'
 * @description By the PEP8 style guide, the first parameter of a normal method should be named `self`.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/not-named-self
 */

import python  // 导入Python库，用于处理Python代码
import MethodArgNames  // 导入MethodArgNames库，用于获取方法参数名称

// 从Function类中选择函数f和字符串message
from Function f, string message
where
  // 检查第一个参数是否应该命名为self且实际没有命名为self
  firstArgShouldBeNamedSelfAndIsnt(f) and
  (
    // 如果存在第一个参数的名称
    if exists(f.getArgName(0))
    then
      // 设置消息内容为：普通方法的第一个参数应该是'self'而不是当前的名称
      message =
        "Normal methods should have 'self', rather than '" + f.getArgName(0) +
          "', as their first parameter."
    else
      // 设置消息内容为：普通方法应该至少有一个参数（第一个参数应该是'self'）
      message =
        "Normal methods should have at least one parameter (the first of which should be 'self')."
  )
// 选择函数f和消息message作为查询结果
select f, message
