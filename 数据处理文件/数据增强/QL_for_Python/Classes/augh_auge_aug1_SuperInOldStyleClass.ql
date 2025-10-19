/**
 * @name 'super' in old style class
 * @description 检测在旧式类中使用 super() 的调用，这种用法会导致运行时错误。
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
  // 检查调用是否发生在旧式类的函数中
  exists(Function containingFunction, ClassObject containingClass |
    // 调用函数名为 "super"
    superCall.getFunc().(Name).getId() = "super" and
    // 调用位于函数作用域内，函数位于类的作用域内
    superCall.getScope() = containingFunction and
    containingFunction.getScope() = containingClass.getPyClass() and
    // 确保类类型推断成功且不是新式类
    not containingClass.failedInference() and
    not containingClass.isNewStyle()
  )
}

// 查询所有调用点
from Call problematicSuperCall
// 筛选在旧式类中使用 super() 的调用点
where superCallInOldStyleClass(problematicSuperCall)
// 输出结果和错误信息
select problematicSuperCall, "'super()' will not work in old-style classes."