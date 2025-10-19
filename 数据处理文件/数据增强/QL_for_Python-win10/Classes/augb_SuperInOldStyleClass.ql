/**
 * @name 'super' in old style class
 * @description 在旧式类中使用 super() 调用会导致运行时错误，因为旧式类不支持新式类的继承机制。
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
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // 调用点必须位于函数作用域内
    superCall.getScope() = enclosingFunction and
    // 该函数必须定义在类的作用域中
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // 确保类对象类型推断成功
    not enclosingClass.failedInference() and
    // 验证类为旧式类（非新式类）
    not enclosingClass.isNewStyle() and
    // 调用目标必须是 super 函数
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查询所有违反规则的 super() 调用
from Call problematicCall
// 筛选条件：调用发生在旧式类中
where superCallInOldStyleClass(problematicCall)
// 输出问题调用点及错误信息
select problematicCall, "'super()' will not work in old-style classes."