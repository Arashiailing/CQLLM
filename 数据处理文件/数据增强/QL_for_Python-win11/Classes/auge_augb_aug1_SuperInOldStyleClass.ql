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

/**
 * 判断给定的调用是否是在旧式类中对 super() 的无效调用
 * @param superCall - 要检查的调用节点
 */
predicate isInvalidSuperCallInOldStyleClass(Call superCall) {
  // 确保调用的是 super 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 检查调用是否发生在函数内部
  exists(Function containingFunction |
    superCall.getScope() = containingFunction and
    // 检查函数是否定义在类内部
    exists(ClassObject parentClass |
      containingFunction.getScope() = parentClass.getPyClass() and
      // 确保类推断成功
      not parentClass.failedInference() and
      // 确保类是旧式类（非新式类）
      not parentClass.isNewStyle()
    )
  )
}

// 查找所有在旧式类中无效的 super() 调用
from Call problematicSuperCall
// 筛选条件：调用是在旧式类中对 super() 的无效调用
where isInvalidSuperCallInOldStyleClass(problematicSuperCall)
// 输出结果和相应的错误信息
select problematicSuperCall, "'super()' will not work in old-style classes."