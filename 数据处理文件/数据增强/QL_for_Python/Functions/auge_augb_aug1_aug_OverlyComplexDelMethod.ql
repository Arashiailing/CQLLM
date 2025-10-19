/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes containing destructors (`__del__` methods) with 
 *              excessive cyclomatic complexity. Destructor methods in Python are called
 *              during object cleanup, which happens at unpredictable times or may be
 *              bypassed in certain conditions. Excessively complex destructors can lead
 *              to performance degradation and unpredictable behavior during garbage
 *              collection. It's recommended to keep these special methods as simple as possible.
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

from FunctionValue delMethod,  // 从FunctionValue类中获取delMethod对象
      ClassValue ownerClass  // 获取拥有该方法的类
where
  // 确认当前方法是某个类的__del__方法
  ownerClass.declaredAttribute("__del__") = delMethod
  and
  // 检查析构方法的圈复杂度是否超过阈值3
  delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
select delMethod, "Overly complex '__del__' method."  // 选择符合条件的delMethod并标记为"过于复杂的`__del__`方法"