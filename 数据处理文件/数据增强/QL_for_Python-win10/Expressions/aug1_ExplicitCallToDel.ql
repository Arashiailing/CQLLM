/**
 * @name Explicit invocation of `__del__` method
 * @description The `__del__` special method is automatically invoked by the Python interpreter
 *              during object finalization. Explicit calls to this method are discouraged as they
 *              may lead to unexpected behavior.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/explicit-call-to-delete
 */

import python  // 导入Python库，用于分析Python代码

// 定义一个名为ExplicitDelCall的类，继承自Call类，用于识别显式调用__del__方法的情况
class ExplicitDelCall extends Call {
  // 构造函数，初始化时检查调用的方法名是否为"__del__"
  ExplicitDelCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // 定义一个谓词isSuperInvocation，用于判断是否是对super的__del__方法的合法调用
  predicate isSuperInvocation() {
    // 存在一个函数func，其名称为"__del__"且在当前作用域中
    exists(Function func | func = this.getScope() and func.getName() = "__del__" |
      // 检查第一个参数是否为self
      func.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 或者调用形式为`super(Type, self).__del__()`或Python 3中的`super().__del__()`
      exists(Call superInvocation | superInvocation = this.getFunc().(Attribute).getObject() |
        superInvocation.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 从ExplicitDelCall类中选择所有不是对super的__del__方法合法调用的实例
from ExplicitDelCall explicitDelCall
where not explicitDelCall.isSuperInvocation()
select explicitDelCall, "The __del__ special method is called explicitly."  // 选择这些实例并报告问题