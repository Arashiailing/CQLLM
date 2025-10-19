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
 * 本查询检测子类方法是否被超类初始化方法中定义的属性遮蔽的情况。
 * 当超类的 __init__ 方法中定义了一个属性，且该属性与子类中的方法同名时，
 * 子类方法将被该属性遮蔽，可能导致意外的行为。
 */

import python

/**
 * 判断子类方法是否被超类属性遮蔽的谓词
 * 
 * 参数说明:
 * - derivedClass: 子类对象
 * - superClass: 超类对象
 * - attrAssignment: 遮蔽子类方法的属性赋值语句
 * - shadowedMethod: 被遮蔽的子类方法
 */
predicate isMethodShadowedBySuperAttribute(
  ClassObject derivedClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 验证类之间的继承关系
  derivedClass.getASuperType() = superClass and
  
  // 确认子类声明了被遮蔽的方法
  derivedClass.declaredAttribute(_) = shadowedMethod and
  
  // 检查超类初始化方法中是否存在同名属性赋值
  exists(
    FunctionObject initMethod,  // 超类的初始化方法
    Attribute assignedAttr      // 被赋值的属性
  |
    // 超类定义了 __init__ 方法
    superClass.declaredAttribute("__init__") = initMethod and
    
    // 属性赋值的目标是 assignedAttr
    assignedAttr = attrAssignment.getATarget() and
    
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = shadowedMethod.getName() and
    
    // 赋值操作发生在超类的初始化方法中
    attrAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（视为有意设计）
  not superClass.hasAttribute(shadowedMethod.getName())
}

/**
 * 查询被遮蔽的方法及其相关信息
 * 
 * 输出:
 * - 被遮蔽的方法位置
 * - 描述信息，指明方法被哪个超类的属性遮蔽
 * - 遮蔽该方法的属性赋值语句
 */
from 
  ClassObject derivedClass,    // 子类对象
  ClassObject superClass,      // 超类对象
  Assign attrAssignment,       // 遮蔽子类方法的属性赋值语句
  FunctionObject shadowedMethod // 被遮蔽的子类方法
where 
  isMethodShadowedBySuperAttribute(derivedClass, superClass, attrAssignment, shadowedMethod)
select 
  shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", 
  attrAssignment, 
  "attribute"