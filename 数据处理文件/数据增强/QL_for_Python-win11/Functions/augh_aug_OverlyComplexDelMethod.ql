/**
 * @name Overly complex `__del__` method
 * @description Detects `__del__` methods with high cyclomatic complexity. In Python, the `__del__` method is called 
 *              during object destruction, which can happen at unpredictable times or may not occur at all. 
 *              Implementations of `__del__` should be kept simple to prevent performance degradation and 
 *              unpredictable behavior during garbage collection cycles.
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

from ClassValue definingClass, FunctionValue destructorMethod  // 从ClassValue和FunctionValue类中获取对象
where
  // 检查是否为类的__del__方法
  definingClass.declaredAttribute("__del__") = destructorMethod and
  // 检查方法的圈复杂度是否超过阈值
  destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorMethod, "Overly complex '__del__' method."  // 选择符合条件的析构方法并标记为过于复杂