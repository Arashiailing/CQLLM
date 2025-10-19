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
 * 检测派生类中定义的方法是否被基类中的属性所遮蔽
 * 这种情况会导致方法调用被属性覆盖，可能引发意外行为
 */

/* 聚焦于在基类构造函数中定义的属性 */
import python

// 判断派生类方法是否被基类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign propertyAssignment, FunctionObject overriddenMethod
) {
  // 确认继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  // 派生类声明了 overriddenMethod 作为其属性
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // 检查基类构造函数中是否存在同名属性赋值
  exists(FunctionObject constructorMethod, Attribute assignedProperty |
    // 基类定义了 __init__ 方法
    baseClass.declaredAttribute("__init__") = constructorMethod and
    // 属性赋值的目标是 assignedProperty
    assignedProperty = propertyAssignment.getATarget() and
    // 属性赋值对象是 self
    assignedProperty.getObject().(Name).getId() = "self" and
    // 属性名称与派生类方法名称相同
    assignedProperty.getName() = overriddenMethod.getName() and
    // 赋值操作发生在基类的构造函数中
    propertyAssignment.getScope() = constructorMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 排除基类中也定义了同名方法的情况
   * 这种情况下，我们认为是有意为之的设计
   */
  // 确保基类没有定义同名属性
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 从派生类、基类、属性赋值和被覆盖的方法中查询
from ClassObject derivedClass, ClassObject baseClass, Assign propertyAssignment, FunctionObject overriddenMethod
// 应用谓词进行筛选
where isMethodShadowedBySuperAttribute(derivedClass, baseClass, propertyAssignment, overriddenMethod)
// 选择被覆盖方法的位置、错误信息、属性赋值位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", propertyAssignment, "attribute"