/**
 * @name Multiple calls to `__del__` during object destruction
 * @description A duplicated call to a super-class `__del__` method may lead to class instances not be cleaned up properly.
 * @kind problem
 * @tags efficiency
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/multiple-calls-to-delete
 */

import python  // 导入python库，用于处理Python代码的查询和分析
import MethodCallOrder  // 导入MethodCallOrder库，用于方法调用顺序的分析

// 定义一个查询，从ClassObject类型的self和FunctionObject类型的multi中选择数据
from ClassObject self, FunctionObject multi
where
  // 条件1：检查是否存在对超类__del__方法的多次调用
  multiple_calls_to_superclass_method(self, multi, "__del__") and
  // 条件2：确保这些多次调用不是在更高层次的基类中发生的
  not multiple_calls_to_superclass_method(self.getABaseType(), multi, "__del__") and
  // 条件3：确保不存在更好的覆盖方法来避免多次调用
  not exists(FunctionObject better |
    multiple_calls_to_superclass_method(self, better, "__del__") and
    better.overrides(multi)
  ) and
  // 条件4：确保没有失败的推断
  not self.failedInference()
select self,
  // 选择结果包括类名和描述信息
  "Class " + self.getName() +
    " may not be cleaned up properly as $@ may be called multiple times during destruction.", multi,
  // 包含被多次调用的方法的描述性字符串
  multi.descriptiveString()
