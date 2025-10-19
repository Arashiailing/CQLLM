/**
 * @name 'super' in old style class
 * @description 在旧式类中使用 super() 调用父类方法会导致运行时错误，因为旧式类不支持此特性。
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
 * 旧式类是不继承自 object 或其他新式类的 Python 类。
 */
predicate isSuperCallInOldStyleClass(Call superInvocation) {
  // 检查调用上下文：必须位于函数内，而该函数又位于类定义内
  exists(Function parentFunction, ClassObject parentClass |
    // 调用位于函数作用域内
    superInvocation.getScope() = parentFunction and
    // 函数定义在类作用域内
    parentFunction.getScope() = parentClass.getPyClass() and
    // 确保类类型推断成功
    not parentClass.failedInference() and
    // 验证类为旧式类（非新式类）
    not parentClass.isNewStyle() and
    // 调用目标必须是 super() 函数
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// 查找所有在旧式类中使用的 super() 调用
from Call invalidSuperCall
// 应用谓词筛选出违规的 super() 调用
where isSuperCallInOldStyleClass(invalidSuperCall)
// 报告问题并提供错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."