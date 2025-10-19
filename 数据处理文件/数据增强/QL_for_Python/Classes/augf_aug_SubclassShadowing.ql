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
 * 检测子类方法被超类属性遮蔽的情况：
 * 1. 子类继承自超类
 * 2. 子类声明了方法
 * 3. 超类在__init__方法中通过self赋值同名属性
 * 4. 超类未定义同名方法（排除有意设计）
 */

import python

// 判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 验证继承关系：子类继承自超类
  derivedClass.getASuperType() = baseClass and
  // 确认子类声明了被遮蔽的方法
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // 检查超类__init__方法中是否存在同名属性赋值
  exists(FunctionObject initMethod, Attribute assignedAttr |
    // 超类必须定义__init__方法
    baseClass.declaredAttribute("__init__") = initMethod and
    // 属性赋值目标对象必须是self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称必须与子类方法名相同
    assignedAttr.getName() = overriddenMethod.getName() and
    // 属性赋值操作必须发生在超类__init__方法中
    attributeAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope() and
    // 关联属性赋值节点
    assignedAttr = attributeAssignment.getATarget()
  ) and
  // 排除超类中已定义同名方法的情况（避免误报有意设计）
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 查询所有满足遮蔽条件的类和方法
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
// 应用遮蔽条件进行筛选
where isMethodShadowedBySuperAttribute(derivedClass, baseClass, attributeAssignment, overriddenMethod)
// 输出结果：被遮蔽方法位置、错误信息、遮蔽属性位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"