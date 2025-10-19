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

// 查找所有在旧式类中使用 super() 调用的代码位置
from Call superCall
where 
  // 确保调用目标是 super() 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 验证调用发生在函数作用域内
  exists(Function enclosingFunction |
    superCall.getScope() = enclosingFunction and
    // 验证函数定义在类作用域内
    exists(ClassObject oldStyleClass |
      enclosingFunction.getScope() = oldStyleClass.getPyClass() and
      // 确保类类型推断成功
      not oldStyleClass.failedInference() and
      // 确认类为旧式类
      not oldStyleClass.isNewStyle()
    )
  )
// 输出问题调用点及错误信息
select superCall, "'super()' will not work in old-style classes."