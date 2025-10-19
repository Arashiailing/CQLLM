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
 * 检测子类方法被超类属性遮蔽的情况
 */

import python

// 定义谓词：判断子类方法是否被超类属性遮蔽
predicate methodShadowedBySuperAttribute(
  ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 确认继承关系
  subClass.getASuperType() = superClass and
  // 子类声明了被遮蔽的方法
  subClass.declaredAttribute(_) = shadowedMethod and
  // 定位超类构造函数中的同名属性赋值
  exists(FunctionObject constructor, Attribute targetAttr |
    // 超类定义了__init__方法
    superClass.declaredAttribute("__init__") = constructor and
    // 属性赋值目标为targetAttr
    targetAttr = attrAssignment.getATarget() and
    // 属性赋值对象是self
    targetAttr.getObject().(Name).getId() = "self" and
    // 属性名与子类方法名相同
    targetAttr.getName() = shadowedMethod.getName() and
    // 赋值发生在超类构造函数作用域内
    attrAssignment.getScope() = constructor.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类中定义同名方法的情况（避免误报）
  not superClass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关上下文
from ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
where methodShadowedBySuperAttribute(subClass, superClass, attrAssignment, shadowedMethod)
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssignment, "attribute"