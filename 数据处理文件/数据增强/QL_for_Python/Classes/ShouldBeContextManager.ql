/**
 * @name Class should be a context manager
 * @description Making a class a context manager allows instances to be used in a 'with' statement.
 *              This improves resource handling and code readability.
 * @kind problem
 * @tags maintainability
 *       readability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision medium
 * @id py/should-be-context-manager
 */

import python

// 从ClassValue类中选择所有不是内建类且不是上下文管理器的类，并且存在__del__方法的类
from ClassValue c
where not c.isBuiltin() // 过滤掉内建类
  and not c.isContextManager() // 过滤掉已经是上下文管理器的类
  and exists(c.declaredAttribute("__del__")) // 检查是否存在__del__方法
select c, // 选择符合条件的类
  "Class " + c.getName() + // 获取类的名称
    " implements __del__ (presumably to release some resource). Consider making it a context manager." // 提示信息，建议将该类改为上下文管理器
