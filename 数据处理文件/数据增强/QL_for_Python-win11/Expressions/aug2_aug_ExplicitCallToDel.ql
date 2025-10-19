/**
 * @name `__del__` is called explicitly
 * @description The `__del__` special method is called by the virtual machine when an object is being finalized. 
 *              It should not be called explicitly in normal circumstances.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个类，表示对__del__方法的显式调用
class ExplicitDelCall extends Call {
  // 构造函数，用于识别所有对__del__方法的显式调用
  ExplicitDelCall() { 
    // 检查调用的方法名是否为"__del__"
    this.getFunc().(Attribute).getName() = "__del__" 
  }

  // 判断当前调用是否为有效的super调用（在__del__方法内部调用父类的__del__）
  predicate isValidSuperCall() {
    // 检查当前调用是否发生在__del__方法定义内部
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

// 查询所有无效的显式__del__方法调用（排除有效的super调用）
from ExplicitDelCall explicitDeletionCall
where not explicitDeletionCall.isValidSuperCall()
select explicitDeletionCall, "The __del__ special method is called explicitly."