/**
 * @name 'super' in old style class
 * @description 在旧式类（未继承object的类）中调用super()会导致运行时错误。
 *              旧式类是Python 2.x的风格，在Python 3中已经移除，但为了兼容性，仍可能存在。
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
 * 旧式类是指未继承object的类（Python 2.x风格）。
 * 在旧式类中使用super()会引发运行时错误。
 */
predicate isSuperCallInOldStyleClass(Call superCall) {
  exists(Function containingFunction, ClassObject containingClass |
    // 确认调用的是super函数
    superCall.getFunc().(Name).getId() = "super" and
    // 确保调用发生在函数内部，且该函数定义在类中
    superCall.getScope() = containingFunction and
    containingFunction.getScope() = containingClass.getPyClass() and
    // 确保类信息能够被正确推断
    not containingClass.failedInference() and
    // 检查类是否为旧式类（非新式类）
    not containingClass.isNewStyle()
  )
}

// 查找所有在旧式类中使用的 super() 调用
from Call superCall
where isSuperCallInOldStyleClass(superCall)
// 输出问题代码和错误信息
select superCall, "'super()' will not work in old-style classes."