/**
 * @name 'super' in old style class
 * @description 使用 super() 访问继承的方法在旧式类中是不被支持的。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

from Call superInvocation
where
  // 验证调用目标是 super() 函数
  superInvocation.getFunc().(Name).getId() = "super" and
  // 确保调用发生在类方法定义中
  exists(Function methodContext, ClassObject classContext |
    // 调用位于函数作用域内
    superInvocation.getScope() = methodContext and
    // 方法定义在类作用域内
    methodContext.getScope() = classContext.getPyClass() and
    // 确保类类型推断成功
    not classContext.failedInference() and
    // 验证类为旧式类（非新式类）
    not classContext.isNewStyle()
  )
select superInvocation, "'super()' will not work in old-style classes."