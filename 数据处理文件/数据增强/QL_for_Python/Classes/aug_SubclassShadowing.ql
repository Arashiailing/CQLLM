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
 * 检测子类中定义的方法是否被超类中的属性所遮蔽的情况
 */

/* 需要定位在超类初始化方法中定义的属性 */
import python

// 定义谓词 isMethodShadowedBySuperAttribute，用于判断子类方法是否被超类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 确认继承关系：subClass 继承自 superClass
  subClass.getASuperType() = superClass and
  // 子类声明了 shadowedMethod 作为其属性
  subClass.declaredAttribute(_) = shadowedMethod and
  // 检查超类初始化方法中是否存在同名属性赋值
  exists(FunctionObject initMethod, Attribute assignedAttr |
    // 超类定义了 __init__ 方法
    superClass.declaredAttribute("__init__") = initMethod and
    // 属性赋值的目标是 assignedAttr
    assignedAttr = attrAssignment.getATarget() and
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    assignedAttr.getName() = shadowedMethod.getName() and
    // 赋值操作发生在超类的初始化方法中
    attrAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 排除超类中也定义了同名方法的情况
   * 这种情况下，我们认为是有意为之的设计
   */
  // 确保超类没有定义同名属性
  not superClass.hasAttribute(shadowedMethod.getName())
}

// 从子类、超类、属性赋值和被遮蔽的方法中查询
from ClassObject subClass, ClassObject superClass, Assign attrAssignment, FunctionObject shadowedMethod
// 应用谓词进行筛选
where isMethodShadowedBySuperAttribute(subClass, superClass, attrAssignment, shadowedMethod)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssignment, "attribute"