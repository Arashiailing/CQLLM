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

// 识别在旧式类中使用的 super() 调用
predicate superCallInOldStyleClass(Call superCall) {
  // 确认调用目标是 super 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 定位包含调用的函数和类上下文
  exists(Function enclosingFunction, ClassObject definingClass |
    // 调用必须位于函数作用域内
    superCall.getScope() = enclosingFunction and
    // 函数必须定义在类作用域内
    enclosingFunction.getScope() = definingClass.getPyClass() and
    // 确保类类型推断成功
    not definingClass.failedInference() and
    // 验证类为旧式类（非新式类）
    not definingClass.isNewStyle()
  )
}

// 查询所有违规的 super() 调用点
from Call invalidSuperCall
// 筛选条件：调用位于旧式类中
where superCallInOldStyleClass(invalidSuperCall)
// 输出问题位置及错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."