/**
 * @name Superclass attribute shadows subclass method
 * @description 在面向对象编程中，当超类初始化方法中定义的属性与子类方法同名时，
 *              会导致子类方法被隐藏，因为属性访问优先于方法查找。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 此查询用于检测超类属性遮蔽子类方法的问题。
 * 当超类的__init__方法内定义了与子类方法同名的属性时，
 * Python的属性查找机制会优先返回属性值而非方法，导致子类方法无法通过实例正常访问。
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 检查继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  
  // 子类中声明了被遮蔽的方法
  derivedClass.declaredAttribute(_) = shadowedMethod and
  
  // 超类初始化方法中存在同名属性赋值
  exists(FunctionObject initMethod, Attribute targetAttr |
    // 超类定义了初始化方法 __init__
    baseClass.declaredAttribute("__init__") = initMethod and
    
    // 属性赋值操作发生在超类的初始化方法作用域内
    attrAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope() and
    
    // 赋值目标是实例属性（通过self引用）
    targetAttr = attrAssignment.getATarget() and
    targetAttr.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    targetAttr.getName() = shadowedMethod.getName()
  ) and
  
  // 确保超类中没有定义同名方法（排除有意设计的情况）
  not baseClass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject derivedClass, ClassObject baseClass, Assign attrAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(derivedClass, baseClass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attrAssignment, "attribute"