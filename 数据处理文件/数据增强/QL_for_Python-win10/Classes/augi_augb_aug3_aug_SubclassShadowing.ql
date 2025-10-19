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
 * 检测子类方法是否被父类属性遮蔽
 * 这种情况会导致方法调用被属性覆盖，可能引发意外行为
 * 聚焦于在父类构造函数中定义的属性
 */

import python

// 判断子类方法是否被父类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMthd
) {
  // 确认继承关系：子类继承自父类
  subCls.getASuperType() = superCls and
  // 子类声明了被遮蔽的方法
  subCls.declaredAttribute(_) = shadowedMthd and
  // 检查父类构造函数中是否存在同名属性赋值
  exists(FunctionObject superInit, Attribute assignedAttr |
    // 父类定义了 __init__ 方法
    superCls.declaredAttribute("__init__") = superInit and
    // 属性赋值的目标是 assignedAttr
    assignedAttr = attrAssign.getATarget() and
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = shadowedMthd.getName() and
    // 赋值操作发生在父类的构造函数中
    attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除父类中也定义了同名方法的情况（有意为之的设计）
  not superCls.hasAttribute(shadowedMthd.getName())
}

// 从子类、父类、属性赋值和被遮蔽的方法中查询
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMthd
// 应用谓词进行筛选
where isMethodShadowedBySuperAttribute(subCls, superCls, attrAssign, shadowedMthd)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select shadowedMthd.getOrigin(),
  "Method " + shadowedMthd.getName() + " is shadowed by an $@ in super class '" + superCls.getName() +
    "'.", attrAssign, "attribute"