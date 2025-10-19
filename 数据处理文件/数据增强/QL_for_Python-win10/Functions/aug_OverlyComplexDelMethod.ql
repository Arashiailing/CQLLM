/**
 * @name Overly complex `__del__` method
 * @description Identifies `__del__` methods with excessive complexity. Python's `__del__` method is invoked during 
 *              object destruction, which can occur at unpredictable times or potentially not at all. These methods 
 *              should be kept simple to avoid performance issues and unpredictable behavior during garbage collection.
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

from FunctionValue deleteMethod  // 从FunctionValue类中获取deleteMethod对象
where
  exists(ClassValue containerClass |  // 检查是否存在一个ClassValue对象containerClass
    containerClass.declaredAttribute("__del__") = deleteMethod and  // 且该类的`__del__`属性等于deleteMethod
    deleteMethod.getScope().getMetrics().getCyclomaticComplexity() > 3  // 且deleteMethod的圈复杂度超过阈值3
  )
select deleteMethod, "Overly complex '__del__' method."  // 选择符合条件的deleteMethod并标记为"过于复杂的`__del__`方法"