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
 */

/*
 * 本查询用于检测子类方法是否被超类初始化方法中定义的属性遮蔽的情况。
 * 这种遮蔽会导致子类方法无法通过实例正常调用，可能引起意外的行为。
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subclass, ClassObject superclass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 确认继承关系：subclass 继承自 superclass
  subclass.getASuperType() = superclass and
  
  // 确认子类声明了被遮蔽的方法
  subclass.declaredAttribute(_) = shadowedMethod and
  
  // 在超类初始化方法中查找同名属性赋值
  exists(FunctionObject initMethod, Attribute attr |
    // 超类定义了 __init__ 方法
    superclass.declaredAttribute("__init__") = initMethod and
    
    // 属性赋值的目标是 attr
    attr = attrAssignment.getATarget() and
    
    // 属性赋值对象是 self
    attr.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    attr.getName() = shadowedMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attrAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（视为有意设计）
  not superclass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject subclass, ClassObject superclass, Assign attrAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(subclass, superclass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attrAssignment, "attribute"