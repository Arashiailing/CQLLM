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

/**
 * 检测子类方法是否被父类属性遮蔽。
 * 当父类在构造函数中通过self赋值定义了一个属性，且该属性与子类方法同名时，
 * 子类方法将被遮蔽。这可能导致方法调用被属性覆盖，引发意外行为。
 */
import python

// 判断子类方法是否被父类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 确认继承关系：childClass 继承自 parentClass
  childClass.getASuperType() = parentClass and
  // 子类声明了 overriddenMethod 作为其属性
  childClass.declaredAttribute(_) = overriddenMethod and
  // 检查父类构造函数中是否存在同名属性赋值
  exists(FunctionObject constructor, Attribute assignedAttribute |
    // 父类定义了 __init__ 方法
    parentClass.declaredAttribute("__init__") = constructor and
    // 属性赋值的目标是 assignedAttribute
    assignedAttribute = attributeAssignment.getATarget() and
    // 属性赋值对象是 self
    assignedAttribute.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    assignedAttribute.getName() = overriddenMethod.getName() and
    // 赋值操作发生在父类的构造函数中
    attributeAssignment.getScope() = constructor.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除父类中也定义了同名方法的情况（避免误报有意为之的设计）
  not parentClass.hasAttribute(overriddenMethod.getName())
}

// 从子类、父类、属性赋值和被遮蔽的方法中查询
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
// 应用谓词进行筛选
where isMethodShadowedBySuperAttribute(childClass, parentClass, attributeAssignment, overriddenMethod)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"