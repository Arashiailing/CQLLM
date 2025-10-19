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
predicate superCallInOldStyleClass(Call superCall) {
  // 存在包含调用的函数和类作用域
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // 调用位于函数作用域内
    superCall.getScope() = enclosingFunction and
    // 函数定义在类作用域内
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // 确保类类型推断成功
    not enclosingClass.failedInference() and
    // 验证类为旧式类
    not enclosingClass.isNewStyle() and
    // 调用目标为 super() 函数
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查询所有违反规则的调用点
from Call problematicCall
// 筛选在旧式类中使用 super() 的情况
where superCallInOldStyleClass(problematicCall)
// 输出问题调用点及错误信息
select problematicCall, "'super()' will not work in old-style classes."