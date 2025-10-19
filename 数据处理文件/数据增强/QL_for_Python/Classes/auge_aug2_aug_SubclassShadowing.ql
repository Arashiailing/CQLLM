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

/* 识别子类方法被超类属性遮蔽的潜在问题：在继承层次结构中，如果超类在初始化方法中定义了与子类方法同名的属性，则子类方法将无法通过正常方式访问 */
import python

// 查找子类方法被超类属性遮蔽的实例
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
where 
  // 确立继承关系：派生类继承自基类
  derivedClass.getASuperType() = baseClass and
  // 派生类中定义了被遮蔽的方法
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // 检查基类初始化方法中是否存在同名属性赋值
  exists(FunctionObject constructor, Attribute assignedAttribute |
    // 基类定义了构造函数__init__
    baseClass.declaredAttribute("__init__") = constructor and
    // 属性赋值的目标是assignedAttribute
    assignedAttribute = attributeAssignment.getATarget() and
    // 属性赋值对象是self实例
    assignedAttribute.getObject().(Name).getId() = "self" and
    // 属性名称与派生类方法名称相同
    assignedAttribute.getName() = overriddenMethod.getName() and
    // 赋值操作发生在基类的构造函数中
    attributeAssignment.getScope() = constructor.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除基类中也定义了同名方法的情况（表明是故意的设计选择）
  not baseClass.hasAttribute(overriddenMethod.getName())
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"