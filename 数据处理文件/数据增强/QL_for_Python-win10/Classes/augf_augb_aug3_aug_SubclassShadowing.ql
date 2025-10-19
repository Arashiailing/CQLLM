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
 * 检测子类方法是否被父类构造函数中的属性遮蔽
 * 这种遮蔽会导致方法调用被属性覆盖，可能引发意外行为
 */

import python

// 判断子类方法是否被父类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 验证继承关系：子类继承自父类
  childClass.getASuperType() = parentClass and
  // 确认子类声明了被遮蔽的方法
  childClass.declaredAttribute(_) = overriddenMethod and
  // 检查父类构造函数中存在同名属性赋值
  exists(FunctionObject initMethod, Attribute assignedAttr |
    // 父类定义了初始化方法
    parentClass.declaredAttribute("__init__") = initMethod and
    // 属性赋值的目标对象是 assignedAttr
    assignedAttr = attributeAssignment.getATarget() and
    // 属性赋值对象为 self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称一致
    assignedAttr.getName() = overriddenMethod.getName() and
    // 赋值操作发生在父类构造函数作用域内
    attributeAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 排除父类中存在同名方法的情况
   * 此类情况被视为有意设计，不视为问题
   */
  not parentClass.hasAttribute(overriddenMethod.getName())
}

// 查询被遮蔽的方法、父类、属性赋值和遮蔽属性
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject overriddenMethod
// 应用遮蔽条件进行筛选
where isMethodShadowedBySuperAttribute(childClass, parentClass, attributeAssignment, overriddenMethod)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"