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

// 检测在旧式类中使用 super() 调用的谓词
predicate superCallInOldStyleClass(Call superInvocation) {
  // 调用目标为 super() 函数
  superInvocation.getFunc().(Name).getId() = "super" and
  // 存在包含调用的函数和类作用域
  exists(Function containingFunction, ClassObject parentClass |
    // 调用位于函数作用域内
    superInvocation.getScope() = containingFunction and
    // 函数定义在类作用域内
    containingFunction.getScope() = parentClass.getPyClass() and
    // 确保类类型推断成功
    not parentClass.failedInference() and
    // 验证类为旧式类
    not parentClass.isNewStyle()
  )
}

// 查询所有违反规则的调用点
from Call invalidSuperCall
// 筛选在旧式类中使用 super() 的情况
where superCallInOldStyleClass(invalidSuperCall)
// 输出问题调用点及错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."