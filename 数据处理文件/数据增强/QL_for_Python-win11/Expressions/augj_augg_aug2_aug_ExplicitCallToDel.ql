/**
 * @name Explicit invocation of `__del__` method
 * @description The `__del__` method is a special method in Python that gets invoked by the garbage collector
 *              when an object is about to be destroyed. Explicitly calling this method is generally considered
 *              bad practice as it can lead to unexpected behavior and violates the intended lifecycle management
 *              of Python objects.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

// 定义类用于识别所有显式调用__del__方法的情况
class DelMethodCall extends Call {
  // 构造函数：筛选出所有调用__del__方法的Call节点
  DelMethodCall() { 
    // 确保被调用的方法名是"__del__"
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  // 判断当前调用是否为合法的super调用场景（通常发生在子类__del__方法中调用父类__del__）
  predicate isValidSuperInvocation() {
    // 检查调用是否发生在某个__del__方法的作用域内
    exists(Function parentFunction | 
      parentFunction = this.getScope() and 
      parentFunction.getName() = "__del__" 
    |
      // 合法场景1: 调用者使用当前实例的self参数
      parentFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 合法场景2: 调用形式为super().__del__()或super(Type, self).__del__()
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() |
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 查询所有非法的显式__del__方法调用（排除合法的super调用场景）
from DelMethodCall explicitDelInvocation
where not explicitDelInvocation.isValidSuperInvocation()
select explicitDelInvocation, "The __del__ special method is called explicitly."