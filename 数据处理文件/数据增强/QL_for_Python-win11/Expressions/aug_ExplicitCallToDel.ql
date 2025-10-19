/**
 * @name `__del__` is called explicitly
 * @description The `__del__` special method is called by the virtual machine when an object is being finalized. It should not be called explicitly.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个名为ExplicitDelCall的类，继承自Call类
class ExplicitDelCall extends Call {
  // 构造函数，初始化时检查调用的方法名是否为"__del__"
  ExplicitDelCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // 定义谓词isValidSuperCall，用于判断是否是对super的__del__方法的调用
  predicate isValidSuperCall() {
    // 检查当前调用是否发生在__del__方法定义内部
    exists(Function currentFunction | 
      currentFunction = this.getScope() and 
      currentFunction.getName() = "__del__" 
    |
      // 情况1: 调用者使用当前对象的self参数
      currentFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 情况2: 调用形式为`super().__del__()`或`super(Type, self).__del__()`
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() |
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 从ExplicitDelCall类中选择所有无效的显式调用（非super调用）
from ExplicitDelCall explicitDelCall
where not explicitDelCall.isValidSuperCall()
select explicitDelCall, "The __del__ special method is called explicitly."  // 选择这些实例并报告问题