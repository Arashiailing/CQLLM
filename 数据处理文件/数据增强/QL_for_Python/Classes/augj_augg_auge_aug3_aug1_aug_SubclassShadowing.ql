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
 * 1. 识别类之间的继承关系（childClass 继承自 parentClass）
 * 2. 定位子类中声明的方法（shadowedMethod），且该方法名与超类__init__中赋值的属性名相同
 * 3. 在超类初始化方法（parentClass.__init__）中查找同名属性赋值（attributeAssignment），该赋值操作针对self
 * 4. 排除超类中已定义同名方法的情况（视为有意设计）
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // 确认继承关系：childClass 继承自 parentClass
  childClass.getASuperType() = parentClass and
  
  // 确认子类声明了被遮蔽的方法，且方法名与shadowedMethod相同
  childClass.declaredAttribute(shadowedMethod.getName()) = shadowedMethod and
  
  // 在超类初始化方法中查找同名属性赋值
  exists(FunctionObject superInitializer, Attribute assignedAttribute |
    // 超类定义了 __init__ 方法
    parentClass.declaredAttribute("__init__") = superInitializer and
    
    // 属性赋值的目标是 assignedAttribute
    assignedAttribute = attributeAssignment.getATarget() and
    
    // 属性赋值对象是 self
    assignedAttribute.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    assignedAttribute.getName() = shadowedMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attributeAssignment.getScope() = superInitializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（视为有意设计）
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(childClass, parentClass, attributeAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"