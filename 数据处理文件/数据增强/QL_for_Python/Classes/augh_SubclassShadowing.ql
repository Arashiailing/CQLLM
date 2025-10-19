/**
 * @name Superclass attribute shadows subclass method
 * @description 定义在超类方法中的一个属性，其名称与子类方法匹配，会隐藏子类的方法。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 检测子类方法是否被超类中定义的属性遮蔽
 * 关键点：超类在__init__方法中定义的属性会遮蔽子类同名方法
 */

import python

// 判断子类方法是否被超类属性遮蔽的谓词
predicate shadowed_by_super_class(
  ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject shadowedMethod
) {
  // 基础继承关系验证
  subClass.getASuperType() = superClass and
  
  // 子类声明了被遮蔽的方法
  subClass.declaredAttribute(_) = shadowedMethod and
  
  // 定位超类中的属性定义
  exists(FunctionObject superInit, Attribute attrNode |
    // 超类必须定义__init__方法
    superClass.declaredAttribute("__init__") = superInit and
    
    // 属性赋值发生在__init__方法内
    attrAssign.getScope() = superInit.getOrigin().(FunctionExpr).getInnerScope() and
    
    // 赋值目标是通过self访问的属性
    attrNode = attrAssign.getATarget() and
    attrNode.getObject().(Name).getId() = "self" and
    
    // 属性名与子类方法名相同
    attrNode.getName() = shadowedMethod.getName()
  ) and
  
  // 排除超类已定义同名方法的情况
  not superClass.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的子类方法
from ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject shadowedMethod
where shadowed_by_super_class(subClass, superClass, attrAssign, shadowedMethod)
// 输出结果：方法位置、描述信息、遮蔽属性位置、属性类型标识
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssign, "attribute"