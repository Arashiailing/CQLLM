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
 * 在 Python 中，这种用法会导致运行时错误。
 */
predicate isSuperCallInOldStyleClass(Call superInvocation) {
  exists(Function methodDef, ClassObject cls |
    // super() 调用必须位于方法内部
    superInvocation.getScope() = methodDef and
    // 方法必须定义在类内部
    methodDef.getScope() = cls.getPyClass() and
    // 确保类的类型推断成功
    not cls.failedInference() and
    // 确认类是旧式类（非新式类）
    not cls.isNewStyle() and
    // 确认调用的是 super 函数
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

from Call superCallExpr
where isSuperCallInOldStyleClass(superCallExpr)
select superCallExpr, "'super()' will not work in old-style classes."