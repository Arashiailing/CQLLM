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
 * 检测在旧式类中使用 super() 调用的谓词
 * 
 * 此谓词识别在旧式类方法中使用 super() 的情况，
 * 这种用法在 Python 中是不被支持的，会导致运行时错误。
 */
predicate detectSuperInOldStyleClass(Call superCall) {
  // 检查是否存在一个方法定义在某个类中
  exists(Function method, ClassObject classObj |
    // 验证调用发生在方法内部
    superCall.getScope() = method and
    // 验证方法定义在类内部
    method.getScope() = classObj.getPyClass() and
    // 确保类的类型推断成功
    not classObj.failedInference() and
    // 确认类是旧式类（非新式类）
    not classObj.isNewStyle() and
    // 验证调用的是 super 函数
    superCall.getFunc().(Name).getId() = "super"
  )
}

// 查询所有调用表达式
from Call callNode
// 筛选出在旧式类中使用 super() 的调用
where detectSuperInOldStyleClass(callNode)
// 返回结果并附带错误信息
select callNode, "'super()' will not work in old-style classes."