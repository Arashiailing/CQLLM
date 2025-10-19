/**
 * @name `__init__` method calls overridden method
 * @description 在`__init__`方法中调用被子类重写的方法可能导致观察到部分初始化的实例。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/init-calls-subclass
 */

import python

from
  ClassObject superClass, string methodName, Call callNode, 
  FunctionObject subMethod, FunctionObject superMethod
where
  // 定位在父类__init__方法中的调用
  exists(FunctionObject initMethod, SelfAttribute selfAttr |
    // 获取父类的__init__方法
    superClass.declaredAttribute("__init__") = initMethod and
    // 确认调用发生在__init__方法作用域内
    callNode.getScope() = initMethod.getFunction() and
    // 确认调用的是self属性
    callNode.getFunc() = selfAttr
  |
    // 获取被调用的方法名称
    selfAttr.getName() = methodName and
    // 获取父类中声明的原始方法
    superMethod = superClass.declaredAttribute(methodName) and
    // 确认存在子类方法重写了父类方法
    subMethod.overrides(superMethod)
  )
// 输出警告信息，包含调用节点、被重写方法和重写方法详情
select callNode, "Call to self.$@ in __init__ method, which is overridden by $@.", 
       superMethod, methodName, subMethod, subMethod.descriptiveString()