/**
 * @name Multiple calls to `__init__` during object initialization
 * @description A duplicated call to a super-class `__init__` method may lead to objects of this class not being properly initialized.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/multiple-calls-to-init
 */

// 导入Python库和MethodCallOrder模块
import python
import MethodCallOrder

// 从ClassObject类型的self和FunctionObject类型的multi中选择数据
from ClassObject self, FunctionObject multi
where
  // 确保multi不是当前类的`__init__`方法，并且存在多次调用超类`__init__`方法的情况
  multi != theObjectType().lookupAttribute("__init__") and
  multiple_calls_to_superclass_method(self, multi, "__init__") and
  // 确保基类没有多次调用超类`__init__`方法
  not multiple_calls_to_superclass_method(self.getABaseType(), multi, "__init__") and
  // 确保不存在更好的覆盖方法
  not exists(FunctionObject better |
    multiple_calls_to_superclass_method(self, better, "__init__") and
    better.overrides(multi)
  ) and
  // 确保推理过程没有失败
  not self.failedInference()
// 选择self和相关信息作为结果输出
select self,
  "Class " + self.getName() +
    " may not be initialized properly as $@ may be called multiple times during initialization.",
  multi, multi.descriptiveString()
