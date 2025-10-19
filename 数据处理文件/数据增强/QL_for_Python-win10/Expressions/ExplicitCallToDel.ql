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

// 定义一个名为DelCall的类，继承自Call类
class DelCall extends Call {
  // 构造函数，初始化时检查调用的方法名是否为"__del__"
  DelCall() { this.getFunc().(Attribute).getName() = "__del__" }

  // 定义一个谓词isSuperCall，用于判断是否是对super的__del__方法的调用
  predicate isSuperCall() {
    // 存在一个函数f，其名称为"__del__"且在当前作用域中
    exists(Function f | f = this.getScope() and f.getName() = "__del__" |
      // 检查第一个参数是否为self
      f.getArg(0).asName().getVariable() = this.getArg(0).(Name).getVariable()
      or
      // 或者调用形式为`super(Type, self).__del__()`或Python 3中的`super().__del__()`
      exists(Call superCall | superCall = this.getFunc().(Attribute).getObject() |
        superCall.getFunc().(Name).getId() = "super"
      )
    )
  }
}

// 从DelCall类中选择所有不是对super的__del__方法调用的实例
from DelCall del
where not del.isSuperCall()
select del, "The __del__ special method is called explicitly."  // 选择这些实例并报告问题
