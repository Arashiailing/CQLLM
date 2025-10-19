/**
 * @name Overly complex `__del__` method
 * @description Identifies Python classes with destructors (`__del__` methods) that exhibit 
 *              high cyclomatic complexity. Python's destructor methods are invoked during
 *              object cleanup, which can occur at non-deterministic times or may be skipped
 *              entirely in specific scenarios. Overly complex destructors can cause performance
 *              issues and erratic behavior during garbage collection cycles. Best practices
 *              suggest maintaining minimal complexity in these special methods.
 * @kind problem
 * @tags efficiency
 *       maintainability
 *       complexity
 *       statistical
 *       non-attributable
 * @problem.severity recommendation
 * @sub-severity low
 * @precision high
 * @id py/overly-complex-delete
 */

import python  // 导入Python分析库，用于代码分析

from FunctionValue destructorMethod  // 从FunctionValue类中获取destructorMethod对象
where
  // 检查是否存在一个拥有该析构方法的类
  exists(ClassValue containingClass | 
    containingClass.declaredAttribute("__del__") = destructorMethod
  )
  and
  // 验证析构方法的圈复杂度超过阈值3
  destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorMethod, "Overly complex '__del__' method."  // 选择符合条件的destructorMethod并标记为"过于复杂的`__del__`方法"