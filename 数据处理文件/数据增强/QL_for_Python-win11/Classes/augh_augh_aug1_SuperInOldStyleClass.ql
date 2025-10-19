/**
 * @name 'super' in old style class
 * @description 在旧式类中使用 super() 调用会导致运行时错误，因为旧式类不支持这种继承机制。
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
 * 识别在旧式类中使用 super() 函数的调用点
 * 
 * Python 中的旧式类（未显式继承自 object 的类）不支持使用 super() 内置函数
 * 来访问父类的方法或属性。当在这种类中使用 super() 时，会引发 TypeError。
 * 此谓词用于定位这些不兼容的用法。
 */
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function parentFunction, ClassObject parentClass |
    // 作用域验证：确保调用发生在类的方法中
    superCall.getScope() = parentFunction and
    parentFunction.getScope() = parentClass.getPyClass() and
    
    // 类属性验证：确保是有效的旧式类
    not parentClass.failedInference() and
    not parentClass.isNewStyle() and
    
    // 调用验证：确保是 super() 函数调用
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查询所有在旧式类中使用的不兼容 super() 调用
from Call problematicSuperCall
where superCallInOldStyleClass(problematicSuperCall)
select problematicSuperCall, "'super()' will not work in old-style classes."