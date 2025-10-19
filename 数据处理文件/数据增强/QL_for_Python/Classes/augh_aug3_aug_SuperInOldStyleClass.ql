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
predicate isSuperCallInOldStyleClass(Call superCallExpr) {
  exists(Function enclosingMethod, ClassObject enclosingClass |
    // 确认调用的是 super 函数
    superCallExpr.getFunc().(Name).getId() = "super" and
    // super() 调用必须位于方法内部
    superCallExpr.getScope() = enclosingMethod and
    // 方法必须定义在类内部
    enclosingMethod.getScope() = enclosingClass.getPyClass() and
    // 确保类的类型推断成功
    not enclosingClass.failedInference() and
    // 确认类是旧式类（非新式类）
    not enclosingClass.isNewStyle()
  )
}

from Call superCallExpr
where isSuperCallInOldStyleClass(superCallExpr)
select superCallExpr, "'super()' will not work in old-style classes."