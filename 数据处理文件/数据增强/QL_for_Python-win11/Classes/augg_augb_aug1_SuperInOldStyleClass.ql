/**
 * @name 'super' in old style class
 * @description 在旧式类中使用 super() 访问继承的方法是不被支持的。
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
 * 判断给定的 super() 调用是否发生在旧式类中。
 * 旧式类是指不继承自 object 的 Python 2.x 风格的类。
 * 在这样的类中使用 super() 会导致运行时错误。
 */
predicate isSuperCallInOldStyleClass(Call superCall) {
  exists(Function containerFunction, ClassObject containerClass |
    // 验证调用发生在函数内部，且该函数定义在类中
    superCall.getScope() = containerFunction and
    containerFunction.getScope() = containerClass.getPyClass() and
    
    // 确保类信息能够被正确推断
    not containerClass.failedInference() and
    
    // 检查类是否为旧式类（非新式类）
    not containerClass.isNewStyle() and
    
    // 确认调用的是 super 函数
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查找所有在旧式类中使用的 super() 调用
from Call problematicSuperCall
where isSuperCallInOldStyleClass(problematicSuperCall)
// 输出问题代码和错误信息
select problematicSuperCall, "'super()' will not work in old-style classes."