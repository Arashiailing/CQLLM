/**
 * @name 'super' in old style class
 * @description 旧式类中不支持使用 super() 调用继承的方法。
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
 * 谓词：识别在旧式类中发生的 super() 调用
 * @param superCall - 被检查的 super() 调用表达式
 */
predicate isSuperCallInOldStyleClass(Call superCall) {
  // 确认调用发生在某个函数内，且该函数定义在旧式类中
  exists(Function containerFunction, ClassObject containerClass |
    // super() 调用位于函数作用域内
    superCall.getScope() = containerFunction and
    // 函数定义在类的作用域内
    containerFunction.getScope() = containerClass.getPyClass() and
    // 类类型推断成功
    not containerClass.failedInference() and
    // 确认是旧式类（非新式类）
    not containerClass.isNewStyle() and
    // 调用的函数名为 "super"
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 检索所有在旧式类中无效的 super() 调用
from Call problematicSuperCall
// 筛选条件：确认调用发生在旧式类中
where isSuperCallInOldStyleClass(problematicSuperCall)
// 输出问题调用及错误描述
select problematicSuperCall, "'super()' will not work in old-style classes."