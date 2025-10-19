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
 * 检测旧式类中不合法的 super() 调用
 * 
 * 此谓词识别在旧式类方法中使用 super() 的代码位置，
 * 这种用法会导致运行时错误，因为旧式类不支持 super() 机制。
 */
predicate isSuperCallInOldStyleClass(Call superCall) {
  // 验证调用的是内置 super 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 确保调用发生在类方法上下文中
  exists(Function method, ClassObject cls |
    // 调用作用域与方法作用域匹配
    superCall.getScope() = method and
    // 方法定义在类的作用域内
    method.getScope() = cls.getPyClass() and
    // 确保类类型推断成功
    not cls.failedInference() and
    // 确认目标类为旧式类（非新式类）
    not cls.isNewStyle()
  )
}

// 查询所有调用表达式
from Call superCall
// 筛选出在旧式类中使用 super() 的调用
where isSuperCallInOldStyleClass(superCall)
// 返回结果并附带错误信息
select superCall, "'super()' will not work in old-style classes."