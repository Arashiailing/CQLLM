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

// 定义谓词：检测在旧式类中对 super() 的无效调用
predicate superCallInOldStyleClass(Call superInvocation) {
  // 检查是否存在包含调用的函数和类，满足以下条件：
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // 调用点位于函数作用域内
    superInvocation.getScope() = enclosingFunction and
    // 函数位于类的作用域内
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // 类类型推断成功
    not enclosingClass.failedInference() and
    // 类不是新式类
    not enclosingClass.isNewStyle() and
    // 调用函数名为 "super"
    superInvocation.getFunc().(Name).getId() = "super"
  )
}

// 查找所有无效的 super() 调用实例
from Call invalidSuperCall
// 筛选条件：调用发生在旧式类中
where superCallInOldStyleClass(invalidSuperCall)
// 输出结果和相应的错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."