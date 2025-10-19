/**
 * @name Overly complex `__del__` method
 * @description Identifies Python classes with `__del__` methods exhibiting high cyclomatic complexity.
 *              Python's `__del__` method is invoked during object destruction, a process that
 *              can occur unpredictably or may be skipped entirely in certain scenarios.
 *              Methods with high complexity in `__del__` can cause performance issues and
 *              erratic behavior during garbage collection cycles. Best practices suggest
 *              maintaining minimal complexity in these special methods.
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

from FunctionValue finalizerMethod  // 从FunctionValue类中获取finalizerMethod对象
where
  exists(ClassValue definingClass |  // 检查是否存在一个ClassValue对象definingClass
    // 验证该方法是类的__del__方法
    definingClass.declaredAttribute("__del__") = finalizerMethod and
    // 检查方法的圈复杂度是否超过阈值3
    finalizerMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select finalizerMethod, "Overly complex '__del__' method."  // 选择符合条件的finalizerMethod并标记为"过于复杂的`__del__`方法"