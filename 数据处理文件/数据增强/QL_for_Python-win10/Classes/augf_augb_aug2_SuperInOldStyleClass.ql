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

// 检测旧式类中super()调用的谓词
predicate superCallInOldClass(Call superCall) {
  // 验证调用目标是super()函数
  superCall.getFunc().(Name).getId() = "super" and
  // 确保调用位于类方法中
  exists(Function enclosingMethod, ClassObject enclosingClass |
    // 调用位于方法作用域内
    superCall.getScope() = enclosingMethod and
    // 方法定义在类作用域内
    enclosingMethod.getScope() = enclosingClass.getPyClass() and
    // 确保类类型推断成功
    not enclosingClass.failedInference() and
    // 验证类是旧式类
    not enclosingClass.isNewStyle()
  )
}

// 查询所有违反规则的super()调用
from Call superCall
// 筛选旧式类中的super()调用
where superCallInOldClass(superCall)
// 输出问题调用点及错误信息
select superCall, "'super()' will not work in old-style classes."