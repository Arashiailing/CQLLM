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

// 检测旧式类中 super() 调用的谓词
predicate uses_of_super_in_old_style_class(Call invocation) {
  // 确保调用发生在函数作用域内
  exists(Function enclosingFunction |
    invocation.getScope() = enclosingFunction and
    // 确保函数定义在类作用域内
    exists(ClassObject containerClass |
      enclosingFunction.getScope() = containerClass.getPyClass() and
      // 验证类对象状态：类型推断成功且非新式类
      not containerClass.failedInference() and
      not containerClass.isNewStyle() and
      // 确认调用目标为 super 函数
      invocation.getFunc().(Name).getId() = "super"
    )
  )
}

// 查询所有满足条件的 super() 调用点
from Call problematicCall
where uses_of_super_in_old_style_class(problematicCall)
select problematicCall, "'super()' will not work in old-style classes."