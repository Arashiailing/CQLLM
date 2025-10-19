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
 * 此查询检测子类方法是否被超类初始化方法中定义的属性遮蔽。
 * 
 * 检测流程：
 * 1. 识别类继承关系：确定子类和超类之间的关系
 * 2. 检查子类方法：在子类中查找可能被遮蔽的方法
 * 3. 检查超类属性：在超类的 __init__ 方法中查找同名属性赋值
 * 4. 排除有意设计：如果超类也定义了同名方法，则视为有意设计，不报告
 */

import python

// 判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 步骤1：确认继承关系
  subclass.getASuperType() = superclass and
  
  // 步骤2：确认子类声明了可能被遮蔽的方法
  subclass.declaredAttribute(_) = overriddenMethod and
  
  // 步骤3：在超类初始化方法中查找同名属性赋值
  exists(FunctionObject initializerMethod, Attribute assignedAttribute |
    // 超类定义了 __init__ 方法
    superclass.declaredAttribute("__init__") = initializerMethod and
    
    // 属性赋值的目标是 assignedAttribute
    assignedAttribute = attributeAssignment.getATarget() and
    
    // 属性赋值对象是 self
    assignedAttribute.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    assignedAttribute.getName() = overriddenMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attributeAssignment.getScope() = initializerMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 步骤4：排除超类中定义同名方法的情况（视为有意设计）
  not superclass.hasAttribute(overriddenMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject overriddenMethod
where isMethodShadowedBySuperAttribute(subclass, superclass, attributeAssignment, overriddenMethod)
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attributeAssignment, "attribute"