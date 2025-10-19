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

/**
 * 判断给定调用是否发生在旧式类中的 super() 调用
 * 旧式类（未继承 object 的类）不支持 super() 机制
 */
predicate isSuperCallInOldStyleClass(Call superInvocation) {
  // 验证调用目标为 super() 函数
  superInvocation.getFunc().(Name).getId() = "super" and
  // 获取包含调用的函数上下文
  exists(Function enclosingFunction |
    superInvocation.getScope() = enclosingFunction and
    // 获取包含函数的类上下文
    exists(ClassObject enclosingClass |
      enclosingFunction.getScope() = enclosingClass.getPyClass() and
      // 确保类类型推断成功
      not enclosingClass.failedInference() and
      // 验证类为旧式类（非新式类）
      not enclosingClass.isNewStyle()
    )
  )
}

/**
 * 查找所有在旧式类中使用 super() 的违规调用点
 * 这些调用会导致运行时错误，因为旧式类没有实现 super() 机制
 */
from Call invalidSuperCall
where isSuperCallInOldStyleClass(invalidSuperCall)
select invalidSuperCall, "'super()' will not work in old-style classes."