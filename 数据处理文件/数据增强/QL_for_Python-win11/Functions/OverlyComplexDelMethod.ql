/**
 * @name Overly complex `__del__` method
 * @description `__del__` methods may be called at arbitrary times, perhaps never called at all, and should be simple.
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

import python  # 导入Python库，用于分析Python代码

from FunctionValue method  # 从FunctionValue类中获取method对象
where
  exists(ClassValue c |  # 检查是否存在一个ClassValue对象c
    c.declaredAttribute("__del__") = method and  # 并且这个类的`__del__`属性等于method
    method.getScope().getMetrics().getCyclomaticComplexity() > 3  # 且method的圈复杂度大于3
  )
select method, "Overly complex '__del__' method."  # 选择符合条件的method并标记为“过于复杂的`__del__`方法”
