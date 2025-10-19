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
 * 查询在旧式类中使用 super() 的调用表达式。
 * 
 * 识别逻辑：
 * 1. 定位所有对内置函数 super() 的调用
 * 2. 验证调用发生在类方法上下文中
 * 3. 确认方法所属类为旧式类（非新式类）
 * 4. 排除类型推断失败的类以避免误报
 */
from Call superCall
where 
  // 验证调用目标为内置 super 函数
  superCall.getFunc().(Name).getId() = "super" and
  // 检查调用上下文是否为类方法
  exists(Function enclosingMethod, ClassObject parentClass |
    // 调用作用域与方法作用域匹配
    superCall.getScope() = enclosingMethod and
    // 方法定义在类的作用域内
    enclosingMethod.getScope() = parentClass.getPyClass() and
    // 确保类的类型推断成功
    not parentClass.failedInference() and
    // 确认目标类为旧式类（非新式类）
    not parentClass.isNewStyle()
  )
select superCall, "'super()' will not work in old-style classes."