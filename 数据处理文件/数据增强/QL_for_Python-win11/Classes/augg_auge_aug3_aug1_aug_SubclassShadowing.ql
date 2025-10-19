/**
 * @name Superclass attribute shadows subclass method
 * @description 在继承层次结构中，当父类的 __init__ 方法中定义的实例属性与子类中定义的方法同名时，
 *              会发生属性遮蔽方法的问题。这会导致运行时行为异常，因为属性赋值会覆盖方法引用，
 *              使得子类方法无法被正常调用。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 此查询通过以下步骤检测子类方法是否被超类属性遮蔽：
 * 1. 识别类之间的继承关系
 * 2. 定位子类中声明的方法
 * 3. 在超类初始化方法中查找同名属性赋值
 * 4. 排除超类中已定义同名方法的情况（视为有意设计）
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 确认继承关系：subClass 继承自 superClass
  subClass.getASuperType() = superClass and
  
  // 确认子类声明了被遮蔽的方法
  subClass.declaredAttribute(_) = shadowedMethod and
  
  // 在超类初始化方法中查找同名属性赋值
  exists(FunctionObject initializer, Attribute targetAttr |
    // 超类定义了 __init__ 方法
    superClass.declaredAttribute("__init__") = initializer and
    
    // 属性赋值的目标是 targetAttr
    targetAttr = attrAssignment.getATarget() and
    
    // 属性赋值对象是 self
    targetAttr.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    targetAttr.getName() = shadowedMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attrAssignment.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（视为有意设计）
  not superClass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(subClass, superClass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssignment, "attribute"