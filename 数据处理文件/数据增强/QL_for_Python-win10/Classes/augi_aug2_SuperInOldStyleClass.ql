/**
 * @name 'super' in old style class
 * @description 在旧式类中使用 super() 访问继承的方法会导致运行时错误，因为旧式类不支持此特性。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// 判断给定的调用是否是在旧式类中对 super() 的调用
predicate isSuperCallInOldStyleClass(Call superInvocation) {
  // 确保调用位于函数作用域内，且该函数定义在类作用域内
  exists(Function parentFunction, ClassObject parentClass |
    // 调用作用域检查：调用必须位于某个函数内
    superInvocation.getScope() = parentFunction and
    // 函数作用域检查：该函数必须定义在某个类内
    parentFunction.getScope() = parentClass.getPyClass() and
    // 确保类类型推断成功，避免误报
    not parentClass.failedInference() and
    // 验证类为旧式类（非新式类）
    not parentClass.isNewStyle() and
    // 确认调用目标是 super() 函数
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// 查询所有在旧式类中无效使用 super() 的调用点
from Call invalidSuperCall
// 筛选条件：调用是在旧式类中对 super() 的调用
where isSuperCallInOldStyleClass(invalidSuperCall)
// 输出问题调用点及错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."