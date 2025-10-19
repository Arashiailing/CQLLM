/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes containing destructor methods (`__del__`) with 
 *              excessive cyclomatic complexity. Destructor methods in Python are executed
 *              during object cleanup, a process that can happen unpredictably or may be
 *              bypassed under certain conditions. Destructors with high complexity can
 *              lead to performance degradation and unpredictable behavior during garbage
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

from FunctionValue destructorFunc, ClassValue ownerClass
where
  // 确认该函数是类的析构方法
  ownerClass.declaredAttribute("__del__") = destructorFunc
  and
  // 检查析构方法的圈复杂度是否超过阈值3
  destructorFunc.getScope().getMetrics().getCyclomaticComplexity() > 3
select destructorFunc, "Overly complex '__del__' method."  // 选择符合条件的destructorFunc并标记为"过于复杂的`__del__`方法"