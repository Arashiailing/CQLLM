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
 * 识别旧式类中不兼容的 super() 调用点
 * 
 * 在 Python 旧式类（未继承 object 的类）中，super() 函数无法正常访问父类方法。
 * 本谓词检测这些会导致运行时错误的调用位置。
 */
predicate superCallInOldStyleClass(Call superCall) {
  exists(Function func, ClassObject cls |
    // 验证调用的是 super 函数
    superCall.getFunc().(Name).getId() = "super" and
    // 确保调用位于函数作用域内
    superCall.getScope() = func and
    // 确保函数定义在类作用域内
    func.getScope() = cls.getPyClass() and
    // 验证类类型推断成功
    not cls.failedInference() and
    // 确认类为旧式类（非新式类）
    not cls.isNewStyle()
  )
}

// 定位所有在旧式类中使用的 super() 调用点
from Call problematicSuperCall
// 筛选符合不兼容条件的 super() 调用
where superCallInOldStyleClass(problematicSuperCall)
// 输出问题调用点及错误信息
select problematicSuperCall, "'super()' will not work in old-style classes."