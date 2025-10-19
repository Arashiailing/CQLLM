/**
 * @name Superclass attribute shadows subclass method
 * @description 当超类中定义的属性与子类方法同名时，会导致子类方法被隐藏。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 *
 * 检测子类中定义的方法是否被超类中的属性所遮蔽的情况。
 * 具体定位在超类初始化方法中定义的属性，这些属性与子类方法同名，
 * 从而导致子类方法被隐藏。同时排除超类中也定义同名方法的情况（即有意覆盖）。
 */

import python

// 判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 确认继承关系：childClass 继承自 parentClass
  childClass.getASuperType() = parentClass and
  // 子类声明了 overriddenMethod 作为其属性
  childClass.declaredAttribute(_) = overriddenMethod and
  // 检查超类初始化方法中是否存在同名属性赋值
  exists(FunctionObject superInitMethod, Attribute assignedAttr |
    // 超类定义了 __init__ 方法
    parentClass.declaredAttribute("__init__") = superInitMethod and
    // 属性赋值的目标是 assignedAttr
    assignedAttr = attributeAssignment.getATarget() and
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = overriddenMethod.getName() and
    // 赋值操作发生在超类的初始化方法中
    attributeAssignment.getScope() = superInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类中也定义了同名方法的情况（有意为之的设计）
  not parentClass.hasAttribute(overriddenMethod.getName())
}

from ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(subClass, superClass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssignment, "attribute"