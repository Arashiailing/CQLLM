/**
 * @name Missing call to `__init__` during object initialization
 * @description An omitted call to a super-class `__init__` method may lead to objects of this class not being fully initialized.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/missing-call-to-init
 */

import python  // 导入python库，用于处理Python代码的解析和分析
import MethodCallOrder  // 导入MethodCallOrder库，用于方法调用顺序的分析

// 定义一个查询，查找在对象初始化期间缺少对`__init__`方法的调用
from ClassObject self, FunctionObject initializer, FunctionObject missing
where
  self.lookupAttribute("__init__") = initializer and  // 当前类的`__init__`方法是initializer
  missing_call_to_superclass_method(self, initializer, missing, "__init__") and  // 检查是否缺少对超类`__init__`方法的调用
  // 如果超类本身也有问题，则不标记当前类
  not missing_call_to_superclass_method(self.getASuperType(), _, missing, "__init__") and
  not missing.neverReturns() and  // 确保缺失的方法不是永远不返回的方法
  not self.failedInference() and  // 确保当前类的推断没有失败
  not missing.isBuiltin() and  // 确保缺失的方法不是内建方法
  not self.isAbstract()  // 确保当前类不是抽象类
select self,
  "Class " + self.getName() + " may not be initialized properly as $@ is not called from its $@.",
  missing, missing.descriptiveString(), initializer, "__init__ method"
