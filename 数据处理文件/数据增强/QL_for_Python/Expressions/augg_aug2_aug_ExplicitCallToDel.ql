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

import python  // 导入Python分析库，提供Python代码分析的基础功能

// 定义一个类，用于识别所有对__del__方法的显式调用情况
class DelMethodInvocation extends Call {
  // 构造函数：筛选出所有调用__del__方法的Call节点
  DelMethodInvocation() { 
    // 确保被调用的方法名是"__del__"
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  // 判断当前调用是否为合法的super调用场景（通常发生在子类__del__方法中调用父类__del__）
  predicate isValidSuperCall() {
    // 检查调用是否发生在某个__del__方法的作用域内
    exists(Function containerFunction | 
      containerFunction = this.getScope() and 
      containerFunction.getName() = "__del__" 
    |
      // 合法场景1: 调用者使用当前实例的self参数
      containerFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 合法场景2: 调用形式为super().__del__()或super(Type, self).__del__()
      exists(Call superInvocation | 
        superInvocation = this.getFunc().(Attribute).getObject() |
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 查询所有非法的显式__del__方法调用（排除合法的super调用场景）
from DelMethodInvocation delInvocation
where not delInvocation.isValidSuperCall()
select delInvocation, "The __del__ special method is called explicitly."