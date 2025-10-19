/**
 * @name Overly complex `__del__` method
 * @description Detects Python `__del__` methods that have high cyclomatic complexity. 
 *              The `__del__` method in Python is called during object destruction, which
 *              can happen at unpredictable times or might not occur at all in certain
 *              circumstances. Complex `__del__` methods can lead to performance degradation
 *              and unpredictable behavior during garbage collection. It's recommended
 *              to keep these methods as simple as possible.
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

from FunctionValue delMethod  // 从FunctionValue类中获取delMethod对象
where
  exists(ClassValue ownerClass |  // 检查是否存在一个ClassValue对象ownerClass
    // 验证该方法是类的__del__方法
    ownerClass.declaredAttribute("__del__") = delMethod and
    // 检查方法的圈复杂度是否超过阈值3
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."  // 选择符合条件的delMethod并标记为"过于复杂的`__del__`方法"