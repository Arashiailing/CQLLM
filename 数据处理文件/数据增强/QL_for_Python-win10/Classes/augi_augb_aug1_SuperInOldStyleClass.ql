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
 * 判断给定的 super() 调用是否位于旧式类中。
 * 旧式类是指没有继承 object 的 Python 2.x 风格类。
 * 在这些类中，super() 调用将无法正常工作。
 */
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function containerFunction, ClassObject containerClass |
    // 调用作用域检查：super() 调用必须位于函数内部
    superCall.getScope() = containerFunction and
    
    // 函数作用域检查：包含 super() 调用的函数必须位于类定义中
    containerFunction.getScope() = containerClass.getPyClass() and
    
    // 类有效性检查：确保类定义是有效的，不是推断失败的类
    not containerClass.failedInference() and
    
    // 类类型检查：确认类不是新式类（即没有继承 object）
    not containerClass.isNewStyle() and
    
    // 调用函数名检查：确认调用的函数名为 "super"
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查找所有在旧式类中使用的 super() 调用
from Call problematicSuperCall
where superCallInOldStyleClass(problematicSuperCall)
select problematicSuperCall, "'super()' will not work in old-style classes."