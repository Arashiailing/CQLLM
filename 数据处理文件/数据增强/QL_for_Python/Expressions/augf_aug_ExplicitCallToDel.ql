/**
 * @name Explicit invocation of `__del__` method
 * @description Detects explicit calls to the `__del__` special method, which should only be invoked by the Python interpreter during object finalization.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个名为ExplicitDelInvocation的类，继承自Call类，用于表示显式调用__del__方法的情况
class ExplicitDelInvocation extends Call {
  // 构造函数，初始化时检查调用的方法名是否为"__del__"
  ExplicitDelInvocation() { this.getFunc().(Attribute).getName() = "__del__" }

  // 定义谓词isValidSuperCall，用于判断是否是对super的__del__方法的合法调用
  predicate isValidSuperCall() {
    // 首先检查当前调用是否发生在__del__方法定义内部
    exists(Function enclosingFunction | 
      enclosingFunction = this.getScope() and 
      enclosingFunction.getName() = "__del__" 
    |
      // 情况1: 调用者使用当前对象的self参数
      enclosingFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 情况2: 调用形式为`super().__del__()`或`super(Type, self).__del__()`
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() |
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 从ExplicitDelInvocation类中选择所有无效的显式调用（非super调用）
from ExplicitDelInvocation explicitDelCall
where not explicitDelCall.isValidSuperCall()
select explicitDelCall, "The __del__ special method is called explicitly."  // 选择这些实例并报告问题