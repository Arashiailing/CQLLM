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
 * 本查询识别子类方法被超类属性遮蔽的情况。
 * 当超类的__init__方法中定义了与子类方法同名的属性时，
 * 子类方法将无法通过实例正常访问，因为Python的属性查找机制会优先返回属性值而非方法。
 */

import python

// 定义谓词：检测子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subclass, ClassObject superclass, Assign attrAssign, FunctionObject hiddenMethod
) {
  // 确认继承关系：subclass 是 superclass 的子类
  subclass.getASuperType() = superclass and
  
  // 子类声明了被隐藏的方法
  subclass.declaredAttribute(_) = hiddenMethod and
  
  // 超类初始化方法中存在同名属性赋值
  exists(FunctionObject initializer, Attribute assignedAttr |
    // 超类定义了初始化方法 __init__
    superclass.declaredAttribute("__init__") = initializer and
    
    // 属性赋值操作发生在超类的初始化方法中
    attrAssign.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope() and
    
    // 赋值目标是实例属性（通过self引用）
    assignedAttr = attrAssign.getATarget() and
    assignedAttr.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = hiddenMethod.getName()
  ) and
  
  // 超类中没有定义同名方法（排除有意设计的情况）
  not superclass.hasAttribute(hiddenMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject subclass, ClassObject superclass, Assign attrAssign, FunctionObject hiddenMethod
where isMethodShadowedBySuperAttribute(subclass, superclass, attrAssign, hiddenMethod)
select hiddenMethod.getOrigin(),
  "Method " + hiddenMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attrAssign, "attribute"