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
 * 检测子类方法是否被超类初始化方法中定义的属性遮蔽的情况
 * 这种情况会导致子类中的方法无法被正常调用，因为属性访问优先于方法查找
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject derivedClass, ClassObject parentClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 1. 确认继承关系：derivedClass 继承自 parentClass
  derivedClass.getASuperType() = parentClass and
  
  // 2. 确认子类声明了被遮蔽的方法
  derivedClass.declaredAttribute(_) = shadowedMethod and
  
  // 3. 在超类初始化方法中查找同名属性赋值
  exists(FunctionObject initMethod, Attribute attrBeingAssigned |
    // 超类定义了 __init__ 方法
    parentClass.declaredAttribute("__init__") = initMethod and
    
    // 属性赋值的目标是 attrBeingAssigned
    attrBeingAssigned = attrAssignment.getATarget() and
    
    // 属性赋值对象是 self
    attrBeingAssigned.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    attrBeingAssigned.getName() = shadowedMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attrAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 4. 排除超类中定义同名方法的情况（视为有意设计）
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject derivedClass, ClassObject parentClass, Assign attrAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(derivedClass, parentClass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attrAssignment, "attribute"