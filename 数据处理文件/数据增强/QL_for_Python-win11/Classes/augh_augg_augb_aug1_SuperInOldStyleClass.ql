/**
 * @name 'super' in old style class
 * @description 旧式类（不继承自object的类）中调用super()会导致运行时错误。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

/**
 * 检查给定的super()调用是否位于旧式类中。
 * 旧式类即未继承object的类（Python 2.x风格）。
 * 在旧式类中使用super()会引发运行时错误。
 */
predicate isSuperCallInOldStyleClass(Call superInvocation) {
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // 确认调用的是 super 函数（快速判断）
    superInvocation.getFunc().(Name).getId() = "super" and
    // 验证调用发生在函数内部，且该函数定义在类中
    superInvocation.getScope() = enclosingFunction and
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // 确保类信息能够被正确推断
    not enclosingClass.failedInference() and
    // 检查类是否为旧式类（非新式类）
    not enclosingClass.isNewStyle()
  )
}

// 查找所有在旧式类中使用的 super() 调用
from Call problematicSuperCall
where isSuperCallInOldStyleClass(problematicSuperCall)
// 输出问题代码和错误信息
select problematicSuperCall, "'super()' will not work in old-style classes."