/**
 * @name Superclass attribute shadows subclass method
 * @description 在继承体系中，若基类的属性与派生类的方法同名，则派生类的方法会被基类的属性所遮蔽。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 本查询用于识别派生类中定义的方法被基类属性遮蔽的情况。
 * 特别关注在基类的__init__方法中通过self赋值定义的属性。
 */

import python

// 定义谓词 isMethodHiddenByBaseClassAttribute，用于判断派生类方法是否被基类属性遮蔽
predicate isMethodHiddenByBaseClassAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 确认继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  // 派生类声明了 overriddenMethod 作为其属性
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // 检查基类初始化方法中是否存在同名属性赋值
  exists(FunctionObject baseInitMethod, Attribute assignedAttr |
    // 基类定义了 __init__ 方法
    baseClass.declaredAttribute("__init__") = baseInitMethod and
    // 属性赋值的目标是 assignedAttr
    assignedAttr = attributeAssignment.getATarget() and
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称与派生类方法名称相同
    assignedAttr.getName() = overriddenMethod.getName() and
    // 赋值操作发生在基类的初始化方法中
    attributeAssignment.getScope() = baseInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 排除基类中也定义了同名方法的情况
   * 这种情况下，我们认为是有意为之的设计
   */
  // 确保基类没有定义同名属性
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 从派生类、基类、属性赋值和被遮蔽的方法中查询
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
// 应用谓词进行筛选
where isMethodHiddenByBaseClassAttribute(derivedClass, baseClass, attributeAssignment, overriddenMethod)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"