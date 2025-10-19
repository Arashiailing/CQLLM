/**
 * @name Overly complex `__del__` method
 * @description The `__del__` special method in Python can be invoked unpredictably or potentially not at all, thus it should be kept simple.
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

import python  // 引入Python代码分析模块

from FunctionValue delMethod  // 定义待分析的函数对象delMethod
where
  // 检查是否存在一个类将delMethod作为其__del__方法，并且该方法的圈复杂度超过3
  exists(ClassValue cls | 
    cls.declaredAttribute("__del__") = delMethod and
    delMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select delMethod, "Overly complex '__del__' method."  // 输出结果