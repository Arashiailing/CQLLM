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
 * 此查询用于检测超类属性遮蔽子类方法的情况：
 * - 子类定义了一个方法
 * - 超类在__init__中定义了一个同名属性
 * - 超类没有定义同名方法
 * 当这些条件满足时，子类方法将被超类属性遮蔽
 */

import python

// 定义谓词检测方法遮蔽情况：子类方法被超类属性遮蔽
predicate shadowed_by_super_class(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeDef, FunctionObject overriddenMethod
) {
  // 建立继承关系：derivedClass继承自baseClass
  derivedClass.getASuperType() = baseClass and
  // 确认子类声明了被遮蔽的方法
  derivedClass.declaredAttribute(_) = overriddenMethod and
  // 检查超类__init__方法中的属性赋值
  exists(FunctionObject initializer, Attribute targetAttribute |
    // 超类声明了__init__方法
    baseClass.declaredAttribute("__init__") = initializer and
    // 赋值目标是一个属性节点
    targetAttribute = attributeDef.getATarget() and
    // 该属性属于self对象
    targetAttribute.getObject().(Name).getId() = "self" and
    // 属性名与子类方法名相同
    targetAttribute.getName() = overriddenMethod.getName() and
    // 赋值发生在__init__方法的作用域内
    attributeDef.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 确保超类没有定义同名方法（避免误报）
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 查询满足遮蔽条件的代码元素
from ClassObject derivedClass, ClassObject baseClass, Assign attributeDef, FunctionObject overriddenMethod
// 应用遮蔽条件谓词进行过滤
where shadowed_by_super_class(derivedClass, baseClass, attributeDef, overriddenMethod)
// 生成检测结果：方法位置、错误信息、属性赋值位置和类型标注
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", attributeDef, "attribute"