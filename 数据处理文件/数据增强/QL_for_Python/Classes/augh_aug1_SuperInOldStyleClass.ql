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
 * 检测在旧式类中使用 super() 的调用点
 * 
 * 在 Python 中，旧式类（不继承自 object 的类）不支持使用 super() 函数
 * 来访问父类方法。此谓词识别这些不兼容的用法。
 */
predicate superCallInOldStyleClass(Call superInvocation) {
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // super() 调用必须位于某个函数内
    superInvocation.getScope() = enclosingFunction and
    // 该函数必须位于某个类内
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // 确保类类型推断成功
    not enclosingClass.failedInference() and
    // 确保类是旧式类（不继承自 object）
    not enclosingClass.isNewStyle() and
    // 确保调用的是 super 函数
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// 查找所有在旧式类中使用 super() 的调用点
from Call invalidSuperCall
// 应用谓词筛选不兼容的 super() 调用
where superCallInOldStyleClass(invalidSuperCall)
// 输出结果和错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."