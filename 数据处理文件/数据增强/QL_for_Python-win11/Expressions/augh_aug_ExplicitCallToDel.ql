/**
 * @name Explicit invocation of `__del__` method
 * @description The `__del__` special method is automatically invoked by the Python interpreter during object finalization. 
 *              Explicitly calling this method can lead to unexpected behavior and should be avoided.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python

// 定义一个继承自Call的类，用于识别显式调用__del__方法的情况
class ExplicitDeletionCall extends Call {
  // 构造函数，筛选出所有调用__del__方法的实例
  ExplicitDeletionCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // 谓词：判断当前调用是否为有效的super().__del__()调用
  predicate isValidSuperCall() {
    // 检查调用是否发生在__del__方法内部
    exists(Function enclosingFunction | 
      enclosingFunction = this.getScope() and 
      enclosingFunction.getName() = "__del__" 
    |
      // 情况1: 调用者使用当前对象的self参数
      enclosingFunction.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 情况2: 调用形式为super().__del__()或super(Type, self).__del__()
      exists(Call superCall | 
        superCall = this.getFunc().(Attribute).getObject() |
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 查询所有显式调用__del__方法但不是有效super调用的实例
from ExplicitDeletionCall explicitDeletionCall
where not explicitDeletionCall.isValidSuperCall()
select explicitDeletionCall, "The __del__ special method is called explicitly."