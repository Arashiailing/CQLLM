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

// 定义谓词：识别在旧式类中使用 super() 的调用点
predicate superCallInOldStyleClass(Call superCall) {
  // 存在包含调用的函数和类，满足以下条件：
  exists(Function containerFunction, ClassObject containerClass |
    // 调用点位于函数作用域内
    superCall.getScope() = containerFunction and
    // 函数位于类的作用域内
    containerFunction.getScope() = containerClass.getPyClass() and
    // 类类型推断成功
    not containerClass.failedInference() and
    // 类不是新式类
    not containerClass.isNewStyle() and
    // 调用函数名为 "super"
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查询所有调用点
from Call problematicCall
// 筛选在旧式类中使用 super() 的调用点
where superCallInOldStyleClass(problematicCall)
// 输出结果和错误信息
select problematicCall, "'super()' will not work in old-style classes."