/**
 * @name `__init__` method calls overridden method
 * @description Calling a method from `__init__` that is overridden by a subclass may result in a partially
 *              initialized instance being observed.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

// 从以下类和对象中导入数据：ClassObject, string, Call, FunctionObject
from
  ClassObject supercls, string method, Call call, FunctionObject overriding,
  FunctionObject overridden
where
  // 检查是否存在一个名为`__init__`的方法，并且该方法在当前作用域内被调用
  exists(FunctionObject init, SelfAttribute sa |
    // 获取类的`__init__`方法并赋值给变量init
    supercls.declaredAttribute("__init__") = init and
    // 确认调用的作用域是`__init__`方法
    call.getScope() = init.getFunction() and
    // 确认调用的是self属性
    call.getFunc() = sa
  |
    // 确认self属性的名称与method相同
    sa.getName() = method and
    // 获取父类中声明的method方法并赋值给overridden
    overridden = supercls.declaredAttribute(method) and
    // 确认子类中的overriding方法重写了父类的overridden方法
    overriding.overrides(overridden)
  )
// 选择符合条件的调用，并生成警告信息
select call, "Call to self.$@ in __init__ method, which is overridden by $@.", overridden, method,
  overriding, overriding.descriptiveString()
