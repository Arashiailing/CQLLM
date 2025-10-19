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
 * 检测子类方法是否被超类属性遮蔽的情况
 */

/* 定位在超类构造函数中定义的属性 */
import python

// 定义谓词 isMethodOverriddenByBaseAttribute，用于判断子类方法是否被超类属性遮蔽
predicate isMethodOverriddenByBaseAttribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeDef, FunctionObject overriddenMethod
) {
  // 确认继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  // 子类声明了 overriddenMethod 作为其属性
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // 检查超类构造函数中是否存在同名属性赋值
  exists(FunctionObject constructorMethod, Attribute targetAttribute |
    // 超类定义了 __init__ 方法
    baseClass.declaredAttribute("__init__") = constructorMethod and
    // 属性赋值的目标是 targetAttribute
    targetAttribute = attributeDef.getATarget() and
    // 属性赋值对象是 self
    targetAttribute.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    targetAttribute.getName() = overriddenMethod.getName() and
    // 赋值操作发生在超类的构造函数中
    attributeDef.getScope() = constructorMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 排除超类中也定义了同名方法的情况
   * 这种情况下，我们认为是有意为之的设计
   */
  // 确保超类没有定义同名属性
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 从子类、超类、属性赋值和被遮蔽的方法中查询
from ClassObject derivedClass, ClassObject baseClass, Assign attributeDef, FunctionObject overriddenMethod
// 应用谓词进行筛选
where isMethodOverriddenByBaseAttribute(derivedClass, baseClass, attributeDef, overriddenMethod)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attributeDef, "attribute"