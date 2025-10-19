/**
 * @name Missing call to `__del__` during object destruction
 * @description An omitted call to a super-class `__del__` method may lead to class instances not being cleaned up properly.
 * @kind problem
 * @tags efficiency
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/missing-call-to-delete
 */

import python  // 导入python库，用于处理Python代码的查询
import MethodCallOrder  // 导入MethodCallOrder库，用于方法调用顺序的分析

// 定义一个查询，查找在对象销毁期间未调用`__del__`方法的情况
from ClassObject self, FunctionObject missing  // 从ClassObject和FunctionObject中选择数据
where
  missing_call_to_superclass_method(self, _, missing, "__del__") and  // 条件1：检查是否缺少对超类`__del__`方法的调用
  not missing.neverReturns() and  // 条件2：确保缺失的方法不是从不返回（即不包含无限循环等）
  not self.failedInference() and  // 条件3：确保类的推断没有失败
  not missing.isBuiltin()  // 条件4：确保缺失的方法不是内建方法
select self,  // 选择要报告的类对象
  "Class " + self.getName() + " may not be cleaned up properly as $@ is not called during deletion.",  // 生成报告信息，指出可能未正确清理的类
  missing, missing.descriptiveString()  // 选择缺失的方法及其描述字符串
