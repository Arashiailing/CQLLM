/**
 * @name Overly complex `__del__` method
 * @description Detects Python classes containing `__del__` methods with excessive cyclomatic complexity.
 *              The `__del__` method in Python serves as a destructor, automatically invoked during
 *              object destruction. However, the timing of this invocation is non-deterministic and
 *              may be bypassed in certain execution contexts. When `__del__` methods exhibit high
 *              complexity, they can introduce performance bottlenecks and unpredictable behavior
 *              during garbage collection. Industry best practices recommend keeping these special
 *              methods as simple as possible to ensure reliable resource cleanup.
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

import python  // 导入Python分析库，提供代码分析的基础功能

from FunctionValue destructorMethod  // 从FunctionValue类中获取destructorMethod对象，代表待分析的析构方法
where
  exists(ClassValue hostClass |  // 检查是否存在一个ClassValue对象hostClass，代表包含析构方法的类
    // 确认目标方法是类的__del__析构方法
    hostClass.declaredAttribute("__del__") = destructorMethod and
    // 评估方法的圈复杂度指标，判断是否超过建议阈值3
    destructorMethod.getScope().getMetrics().getCyclomaticComplexity() > 3
  )
select destructorMethod, "Overly complex '__del__' method."  // 输出符合条件的destructorMethod并附上描述信息