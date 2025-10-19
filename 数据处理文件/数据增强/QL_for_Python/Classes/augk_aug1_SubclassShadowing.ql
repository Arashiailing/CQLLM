/**
 * @name Superclass attribute shadows subclass method
 * @description 当超类在初始化方法中定义的属性与子类方法同名时，会遮蔽子类方法。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/* 
 * 检测场景：超类属性遮蔽子类方法
 * 关键逻辑：
 * 1. 识别类继承关系
 * 2. 验证超类在初始化方法中定义了同名属性
 * 3. 确保超类本身未定义同名方法
 */

import python

// 检测子类方法是否被超类属性遮蔽
predicate is_shadowed_by_superclass(
  ClassObject derivedClass, ClassObject baseClass, Assign concealingAssignment, FunctionObject obscuredMethod
) {
  // 确认继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  // 验证子类中存在被遮蔽的方法
  derivedClass.declaredAttribute(_) = obscuredMethod and
  // 检查超类初始化方法中的属性定义
  exists(FunctionObject baseInitializer, Attribute prop, string methodIdentifier |
    // 超类必须定义 __init__ 方法
    baseClass.declaredAttribute("__init__") = baseInitializer and
    // 赋值语句的目标属性
    prop = concealingAssignment.getATarget() and
    // 属性必须属于 self 对象
    prop.getObject().(Name).getId() = "self" and
    // 属性名与方法名匹配
    methodIdentifier = obscuredMethod.getName() and
    prop.getName() = methodIdentifier and
    // 赋值操作必须发生在超类的 __init__ 作用域内
    concealingAssignment.getScope() = baseInitializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类已定义同名方法的情况（避免误报）
  not baseClass.hasAttribute(obscuredMethod.getName())
}

// 主查询：定位被遮蔽的方法
from ClassObject derivedClass, ClassObject baseClass, Assign concealingAssignment, FunctionObject obscuredMethod
where is_shadowed_by_superclass(derivedClass, baseClass, concealingAssignment, obscuredMethod)
// 输出格式保持不变：方法位置 + 描述信息 + 遮蔽赋值位置 + 属性类型
select obscuredMethod.getOrigin(),
  "Method " + obscuredMethod.getName() + " is shadowed by an $@ in super class '" + baseClass.getName() +
    "'.", concealingAssignment, "attribute"