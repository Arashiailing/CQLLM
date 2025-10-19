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

import python

// 定义一个类，用于表示显式调用__del__方法的情况
class ExplicitDelCall extends Call {
  // 构造函数：识别所有调用__del__方法的表达式
  ExplicitDelCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // 判断是否为对父类__del__方法的合法调用
  predicate isSuperCall() {
    // 检查当前调用是否发生在__del__方法内部
    exists(Function func | func = this.getScope() and func.getName() = "__del__" |
      // 情况1：通过self参数调用自身的__del__方法
      func.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 情况2：通过super()调用父类的__del__方法
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() and
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 查询所有显式调用__del__方法但不是合法父类调用的情况
from ExplicitDelCall explicitDelCall
where not explicitDelCall.isSuperCall()
select explicitDelCall, "The __del__ special method is called explicitly."