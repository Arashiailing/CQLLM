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
 * 检测在旧式类中对 super() 的无效调用
 * 此谓词识别所有在旧式类环境中使用 super() 的情况，
 * 这些情况在 Python 中会导致运行时错误。
 * @param superInvocation - 待分析的 super() 调用节点
 */
predicate isInvalidSuperCallInOldStyleClass(Call superInvocation) {
  // 验证调用目标为 super 函数
  superInvocation.getFunc().(Name).getId() = "super" and
  // 确保调用发生在函数定义体内
  exists(Function enclosingFunction |
    superInvocation.getScope() = enclosingFunction and
    // 验证函数定义在类作用域内
    exists(ClassObject hostClass |
      enclosingFunction.getScope() = hostClass.getPyClass() and
      // 确保类解析成功且非新式类
      not hostClass.failedInference() and
      not hostClass.isNewStyle()
    )
  )
}

// 查询所有在旧式类中对 super() 的无效使用
from Call invalidSuperUsage
where isInvalidSuperCallInOldStyleClass(invalidSuperUsage)
select invalidSuperUsage, "'super()' will not work in old-style classes."