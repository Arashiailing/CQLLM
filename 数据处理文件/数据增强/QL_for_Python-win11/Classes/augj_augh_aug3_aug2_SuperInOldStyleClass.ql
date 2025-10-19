/**
 * @name 'super' in old style class
 * @description 旧式类中不支持使用 super() 访问继承方法
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
  // 检查调用的是否为 super() 函数
  superInvocation.getFunc().(Name).getId() = "super" and
  // 验证调用发生在类定义的方法中
  exists(Function containingMethod, ClassObject hostClass |
    // 调用位于方法内
    superInvocation.getScope() = containingMethod and
    // 方法位于类内
    containingMethod.getScope() = hostClass.getPyClass() and
    // 确保类可以被正确分析
    not hostClass.failedInference() and
    // 确认该类是旧式类（非新式类）
    not hostClass.isNewStyle()
  )
select superInvocation, "'super()' will not work in old-style classes."