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
  ClassObject derivedClass, ClassObject baseClass, Assign attrAssign, FunctionObject shadowedMethod
) {
  // 验证继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  // 确认子类声明了 shadowedMethod 作为其属性
  derivedClass.declaredAttribute(_) = shadowedMethod and
  // 检查超类初始化方法中是否存在同名属性赋值
  exists(FunctionObject baseInitMethod, Attribute targetAttr |
    // 超类定义了 __init__ 方法
    baseClass.declaredAttribute("__init__") = baseInitMethod and
    // 属性赋值的目标是 targetAttr
    targetAttr = attrAssign.getATarget() and
    // 属性赋值对象是 self
    targetAttr.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    targetAttr.getName() = shadowedMethod.getName() and
    // 赋值操作发生在超类的初始化方法中
    attrAssign.getScope() = baseInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类中也定义了同名方法的情况（有意为之的设计）
  not baseClass.hasAttribute(shadowedMethod.getName())
}

from ClassObject derivedClass, ClassObject baseClass, Assign attrAssign, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(derivedClass, baseClass, attrAssign, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attrAssign, "attribute"