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
 * 本查询通过分析类继承体系、属性定义和方法声明，检测子类方法是否被超类
 * 初始化方法中定义的属性遮蔽的情况。核心检测逻辑包括：
 * 1. 验证类之间的直接继承关系
 * 2. 确认子类声明了被遮蔽的方法
 * 3. 在超类初始化方法中定位同名属性赋值
 * 4. 排除超类中存在同名方法的情况（视为有意设计）
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // 验证继承关系：subclass 直接继承自 superclass
  subclass.getASuperType() = superclass and
  
  // 确认子类声明了被遮蔽的方法
  subclass.declaredAttribute(shadowedMethod.getName()) = shadowedMethod and
  
  // 在超类初始化方法中查找同名属性赋值
  exists(FunctionObject superInitMethod, Attribute attributeTarget |
    // 超类定义了 __init__ 方法
    superclass.declaredAttribute("__init__") = superInitMethod and
    
    // 属性赋值的目标是 attributeTarget
    attributeTarget = attributeAssignment.getATarget() and
    
    // 属性赋值对象是 self
    attributeTarget.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    attributeTarget.getName() = shadowedMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attributeAssignment.getScope() = superInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（视为有意设计）
  not superclass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关信息
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
where isMethodShadowedBySuperAttribute(subclass, superclass, attributeAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attributeAssignment, "attribute"