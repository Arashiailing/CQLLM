/**
 * @name 'super' in old style class
 * @description 检测在旧式类中使用 super() 调用的情况，这种用法在 Python 中是不被支持的，
 *              因为旧式类没有实现新式类的 MRO (Method Resolution Order) 机制。
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

// 判断给定的调用是否是在旧式类中的 super() 调用
predicate isSuperCallInOldStyleClass(Call superCall) {
  // 验证调用目标是 super() 函数
  exists(Name funcName | 
    funcName = superCall.getFunc() and 
    funcName.getId() = "super"
  ) and
  // 获取包含调用的函数和类作用域
  exists(Function enclosingFunction, ClassObject enclosingClass |
    // 确保调用位于函数作用域内
    superCall.getScope() = enclosingFunction and
    // 确保函数定义在类作用域内
    enclosingFunction.getScope() = enclosingClass.getPyClass() and
    // 验证类类型推断成功
    not enclosingClass.failedInference() and
    // 确保类为旧式类（未继承自 object 或其他新式类）
    not enclosingClass.isNewStyle()
  )
}

// 查询所有在旧式类中使用 super() 的调用点
from Call invalidSuperCall
// 筛选条件：调用是在旧式类中的 super() 调用
where isSuperCallInOldStyleClass(invalidSuperCall)
// 输出问题调用点及相应的错误信息
select invalidSuperCall, "'super()' will not work in old-style classes."