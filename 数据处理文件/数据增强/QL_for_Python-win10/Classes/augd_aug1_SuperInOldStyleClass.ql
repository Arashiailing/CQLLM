/**
 * @name 'super' in old style class
 * @description 检测在旧式类中使用 super() 调用的代码模式，这在Python中是不支持的语法。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// 主查询：识别所有在旧式类中调用 super() 的代码位置
from Call faultySuperCall
// 检查条件：调用必须发生在旧式类的上下文中
where exists(Function enclosingFunction, ClassObject parentClass |
  // 确保调用位于函数作用域内
  faultySuperCall.getScope() = enclosingFunction and
  // 确保函数位于类的作用域内
  enclosingFunction.getScope() = parentClass.getPyClass() and
  // 验证类类型推断成功
  not parentClass.failedInference() and
  // 确认类是旧式类（非新式类）
  not parentClass.isNewStyle() and
  // 验证调用的是 super 函数
  faultySuperCall.getFunc().(Name).getId() = "super"
)
// 输出检测结果和相应的错误提示信息
select faultySuperCall, "'super()' will not work in old-style classes."