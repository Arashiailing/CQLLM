/**
 * @name Superclass attribute shadows subclass method
 * @description 定义在超类方法中的一个属性，其名称与子类方法匹配，会隐藏子类的方法。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/* 
 * 检测场景：子类中定义的方法被超类中定义的属性遮蔽
 * 关键逻辑：
 * 1. 确定子类与超类的继承关系
 * 2. 验证超类在初始化方法中定义了同名属性
 * 3. 确保超类本身未定义同名方法
 */

import python

// 检测子类方法是否被超类属性遮蔽
predicate shadowed_by_super_class(
  ClassObject subcls, ClassObject superclass, Assign shadowingAssign, FunctionObject shadowedMethod
) {
  // 验证继承关系：subcls 继承自 superclass
  subcls.getASuperType() = superclass and
  // 确认子类中存在被遮蔽的方法
  subcls.declaredAttribute(_) = shadowedMethod and
  // 检查超类初始化方法中的属性定义
  exists(FunctionObject superInit, Attribute attr, string methodName |
    // 超类必须定义 __init__ 方法
    superclass.declaredAttribute("__init__") = superInit and
    // 赋值语句的目标属性
    attr = shadowingAssign.getATarget() and
    // 属性必须属于 self 对象
    attr.getObject().(Name).getId() = "self" and
    // 属性名与方法名匹配
    methodName = shadowedMethod.getName() and
    attr.getName() = methodName and
    // 赋值操作必须发生在超类的 __init__ 作用域内
    shadowingAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类已定义同名方法的情况（避免误报）
  not superclass.hasAttribute(shadowedMethod.getName())
}

// 主查询：定位被遮蔽的方法
from ClassObject subcls, ClassObject superclass, Assign shadowingAssign, FunctionObject shadowedMethod
where shadowed_by_super_class(subcls, superclass, shadowingAssign, shadowedMethod)
// 输出格式保持不变：方法位置 + 描述信息 + 遮蔽赋值位置 + 属性类型
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", shadowingAssign, "attribute"