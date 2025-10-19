/**
 * @name Superclass attribute shadows subclass method
 * @description 超类属性遮蔽子类方法是指在继承体系中，超类的 __init__ 方法中定义的实例属性
 *              与子类中定义的方法同名，导致子类方法无法正常访问的问题。这种情况会导致
 *              运行时行为异常，因为属性赋值会覆盖方法引用。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 本查询通过分析类继承关系、属性定义和方法声明，检测子类方法是否被超类
 * 初始化方法中定义的属性遮蔽的情况。具体检测逻辑包括：
 * 1. 确认类之间的继承关系
 * 2. 检查子类中声明的方法
 * 3. 在超类初始化方法中查找同名属性赋值
 * 4. 排除超类中定义同名方法的情况（视为有意设计）
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 确认继承关系：childClass 继承自 parentClass
  childClass.getASuperType() = parentClass and
  
  // 确认子类声明了被遮蔽的方法
  childClass.declaredAttribute(_) = overriddenMethod and
  
  // 在超类初始化方法中查找同名属性赋值
  exists(FunctionObject initMethod, Attribute assignedAttr |
    // 超类定义了 __init__ 方法
    parentClass.declaredAttribute("__init__") = initMethod and
    
    // 属性赋值的目标是 assignedAttr
    assignedAttr = attributeAssignment.getATarget() and
    
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = overriddenMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attributeAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（视为有意设计）
  not parentClass.hasAttribute(overriddenMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
where isMethodShadowedBySuperAttribute(childClass, parentClass, attributeAssignment, overriddenMethod)
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"