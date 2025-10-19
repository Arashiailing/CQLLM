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

/**
 * 检测在旧式类中使用 super() 调用的情况。
 * 在 Python 中，旧式类不支持使用 super() 访问继承的方法，这会导致运行时错误。
 */
predicate isSuperCallInOldStyleClass(Call superInvocation) {
  exists(Function methodContainingSuper, ClassObject oldStyleClass |
    // 确认调用的是 super 函数
    superInvocation.getFunc().(Name).getId() = "super" and
    // super() 调用必须位于方法内部
    superInvocation.getScope() = methodContainingSuper and
    // 方法必须定义在类内部
    methodContainingSuper.getScope() = oldStyleClass.getPyClass() and
    // 确保类的类型推断成功
    not oldStyleClass.failedInference() and
    // 确认类是旧式类（非新式类）
    not oldStyleClass.isNewStyle()
  )
}

from Call superInvocation
where isSuperCallInOldStyleClass(superInvocation)
select superInvocation, "'super()' will not work in old-style classes."