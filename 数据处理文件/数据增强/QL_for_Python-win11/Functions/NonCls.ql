/**
 * @name First parameter of a class method is not named 'cls'
 * @description By the PEP8 style guide, the first parameter of a class method should be named `cls`.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/not-named-cls
 */

import python  # 导入python模块，用于处理Python代码
import MethodArgNames  # 导入MethodArgNames库，用于获取方法参数名

from Function f, string message  # 从Function类型和字符串message中选择数据
where
  firstArgShouldReferToClsAndDoesnt(f) and  # 条件：第一个参数应该引用类但未引用
  (
    if exists(f.getArgName(0))  # 如果存在第一个参数名
    then
      message =
        "Class methods or methods of a type deriving from type should have 'cls', rather than '" +
          f.getArgName(0) + "', as their first parameter."  # 设置消息内容，指出应使用'cls'而不是当前参数名
    else
      message =
        "Class methods or methods of a type deriving from type should have 'cls' as their first parameter."  # 设置消息内容，指出应使用'cls'作为第一个参数
  )
select f, message  # 选择函数f和消息message
