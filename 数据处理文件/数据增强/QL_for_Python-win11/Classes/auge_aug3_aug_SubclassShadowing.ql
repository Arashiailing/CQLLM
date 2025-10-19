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
 * 检测子类中声明的方法是否被父类中的同名属性所遮蔽
 * 这种遮蔽会导致方法调用被属性引用取代，可能引起程序行为异常
 */

/* 聚焦于父类构造函数中初始化的属性 */
import python

// 判断子类方法是否被父类属性遮蔽
predicate isMethodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
) {
  // 确认继承关系：childClass 继承自 parentClass
  childClass.getASuperType() = parentClass and
  // 子类声明了 shadowedMethod 作为其方法
  childClass.declaredAttribute(_) = shadowedMethod and
  // 检查父类构造函数中是否存在同名属性赋值
  exists(FunctionObject initMethod, Attribute attributeProp |
    // 父类定义了 __init__ 方法
    parentClass.declaredAttribute("__init__") = initMethod and
    // 属性赋值的目标是 attributeProp
    attributeProp = attributeAssignment.getATarget() and
    // 属性赋值对象是 self
    attributeProp.getObject().(Name).getId() = "self" and
    // 属性名称与子类方法名称相同
    attributeProp.getName() = shadowedMethod.getName() and
    // 赋值操作发生在父类的构造函数中
    attributeAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 排除父类中也定义了同名方法的情况
   * 如果父类也有同名方法，则认为是正常的方法重写而非遮蔽问题
   */
  // 确保父类没有定义同名属性
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// 从子类、父类、属性赋值和被遮蔽的方法中查询
from ClassObject childClass, ClassObject parentClass, Assign attributeAssignment, FunctionObject shadowedMethod
// 应用谓词进行筛选
where isMethodShadowedBySuperAttribute(childClass, parentClass, attributeAssignment, shadowedMethod)
// 选择被遮蔽方法的位置、错误信息、属性赋值位置和属性类型
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attributeAssignment, "attribute"