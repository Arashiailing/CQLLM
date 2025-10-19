/**
 * @name 'super' in old style class
 * @description 旧式类中不支持使用 super() 访问继承方法
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/super-in-old-style
 */

import python

from Call superCall 
where
  // 验证调用目标是 super() 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 确保调用发生在定义于类内的函数中
  exists(Function enclosingMethod, ClassObject parentClass |
    superCall.getScope() = enclosingMethod and
    enclosingMethod.getScope() = parentClass.getPyClass() and
    // 排除类型推断失败的类
    not parentClass.failedInference() and
    // 确认父类是旧式类
    not parentClass.isNewStyle()
  )
select superCall, "'super()' will not work in old-style classes."