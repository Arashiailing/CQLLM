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

/* 检测子类方法被超类属性遮蔽的情况：当超类初始化方法中定义了与子类方法同名的属性时，子类方法将被隐藏 */
import python

// 查询子类方法被超类属性遮蔽的情况
from ClassObject subclass, ClassObject superclass, Assign attributeAssignment, FunctionObject shadowedMethod
where 
  // 确认继承关系：子类继承自超类
  subclass.getASuperType() = superclass and
  // 子类声明了被遮蔽的方法
  subclass.declaredAttribute(_) = shadowedMethod and
  // 检查超类初始化方法中是否存在同名属性赋值
  exists(FunctionObject initializer, Attribute attributeTarget |
    // 超类定义了__init__方法
    superclass.declaredAttribute("__init__") = initializer and
    // 属性赋值的目标是attributeTarget
    attributeTarget = attributeAssignment.getATarget() and
    // 属性赋值对象是self
    attributeTarget.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    attributeTarget.getName() = shadowedMethod.getName() and
    // 赋值操作发生在超类的初始化方法中
    attributeAssignment.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类中也定义了同名方法的情况（有意为之的设计）
  not superclass.hasAttribute(shadowedMethod.getName())
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attributeAssignment, "attribute"