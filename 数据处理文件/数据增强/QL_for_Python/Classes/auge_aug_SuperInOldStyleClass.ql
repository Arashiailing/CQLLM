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
 * 识别在旧式类中不正确使用 super() 调用的谓词
 * 
 * 此谓词用于标记在旧式类方法中使用 super() 的代码位置，
 * 这种用法在 Python 中会导致运行时错误，因为旧式类不支持 super() 机制。
 */
predicate identifySuperInOldStyleClass(Call superInvocation) {
  // 确保调用的是内置 super 函数
  superInvocation.getFunc().(Name).getId() = "super" and
  // 检查调用是否发生在某个类方法内部
  exists(Function classMethod, ClassObject targetClass |
    // 调用作用域与方法作用域匹配
    superInvocation.getScope() = classMethod and
    // 方法定义在类的作用域内
    classMethod.getScope() = targetClass.getPyClass() and
    // 确保类的类型推断成功
    not targetClass.failedInference() and
    // 确认目标类为旧式类（非新式类）
    not targetClass.isNewStyle()
  )
}

// 查询所有调用表达式
from Call invalidSuperCall
// 筛选出在旧式类中使用 super() 的调用
where identifySuperInOldStyleClass(invalidSuperCall)
// 返回结果并附带错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."