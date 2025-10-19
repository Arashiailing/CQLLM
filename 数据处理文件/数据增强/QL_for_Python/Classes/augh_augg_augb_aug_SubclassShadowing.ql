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
 * 逻辑说明：
 * 1. 确认继承关系：子类继承自超类
 * 2. 子类声明了被遮蔽的方法
 * 3. 超类构造函数中存在同名属性赋值
 * 4. 排除超类中定义同名方法的情况
 */

import python

// 判断子类方法是否被超类属性遮蔽
predicate methodShadowedBySuperAttribute(
  ClassObject childClass, ClassObject parentClass, Assign attrAssignment, FunctionObject overriddenMethod
) {
  // 确认继承关系
  childClass.getASuperType() = parentClass and
  
  // 子类声明了被遮蔽的方法
  childClass.declaredAttribute(_) = overriddenMethod and
  
  // 定位超类构造函数中的同名属性赋值
  exists(FunctionObject superConstructor, Attribute attributeTarget |
    // 超类定义了__init__方法
    parentClass.declaredAttribute("__init__") = superConstructor and
    
    // 属性赋值目标为attributeTarget
    attributeTarget = attrAssignment.getATarget() and
    
    // 属性赋值对象是self
    attributeTarget.getObject().(Name).getId() = "self" and
    
    // 属性名与子类方法名相同
    attributeTarget.getName() = overriddenMethod.getName() and
    
    // 赋值发生在超类构造函数作用域内
    attrAssignment.getScope() = superConstructor.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除超类中定义同名方法的情况（避免误报）
  not parentClass.hasAttribute(overriddenMethod.getName())
}

// 查询被遮蔽的方法及其相关上下文
from ClassObject childClass, ClassObject parentClass, Assign attrAssignment, FunctionObject overriddenMethod
where methodShadowedBySuperAttribute(childClass, parentClass, attrAssignment, overriddenMethod)
select overriddenMethod.getOrigin(),
  "Method " + overriddenMethod.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attrAssignment, "attribute"