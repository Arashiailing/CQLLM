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

/* 检测继承层次中的方法遮蔽问题：当超类在初始化方法中定义了与子类方法同名的属性时，
   会导致子类方法无法通过正常方式访问，可能引起意外的行为和难以调试的问题。 */
import python

// 查找子类方法被超类属性遮蔽的实例
from ClassObject subclass, ClassObject superclass, Assign shadowingAttribute, FunctionObject shadowedMethod
where 
  // 确立继承关系：子类继承自超类
  subclass.getASuperType() = superclass and
  // 子类中定义了被遮蔽的方法
  subclass.declaredAttribute(_) = shadowedMethod and
  // 检查超类初始化方法中是否存在同名属性赋值
  exists(FunctionObject superclassConstructor, Attribute assignedAttr |
    // 超类定义了构造函数__init__
    superclass.declaredAttribute("__init__") = superclassConstructor and
    // 属性赋值的目标是assignedAttr
    assignedAttr = shadowingAttribute.getATarget() and
    // 属性赋值对象是self实例
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = shadowedMethod.getName() and
    // 赋值操作发生在超类的构造函数中
    shadowingAttribute.getScope() = superclassConstructor.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类中也定义了同名方法的情况（表明是故意的设计选择）
  not superclass.hasAttribute(shadowedMethod.getName())
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", shadowingAttribute, "attribute"