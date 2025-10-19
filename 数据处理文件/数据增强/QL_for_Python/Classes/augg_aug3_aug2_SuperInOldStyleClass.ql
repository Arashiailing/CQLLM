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

// 检测旧式类中 super() 调用的谓词
predicate superCallInOldStyleClass(Call superCall) {
  // 验证调用目标为 super() 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 确保调用发生在函数作用域内
  exists(Function enclosingFunction |
    superCall.getScope() = enclosingFunction and
    // 确保函数定义在类作用域内
    exists(ClassObject oldStyleClass |
      enclosingFunction.getScope() = oldStyleClass.getPyClass() and
      // 验证类推断成功且为旧式类
      not oldStyleClass.failedInference() and
      not oldStyleClass.isNewStyle()
    )
  )
}

// 查询所有违规的 super() 调用点
from Call invalidSuperCall
// 筛选在旧式类中使用 super() 的情况
where superCallInOldStyleClass(invalidSuperCall)
// 输出问题调用点及错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."