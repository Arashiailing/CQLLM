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
 * 该查询检测子类方法是否被超类中定义的属性遮蔽。
 * 遮蔽机制：当超类在其__init__方法中定义了一个属性，且该属性名称与子类中的方法名称相同时，
 * 子类的方法将被超类的属性遮蔽，导致无法通过实例访问子类方法。
 */

import python

// 判断子类方法是否被超类属性遮蔽的谓词
predicate method_shadowed_by_superclass_attribute(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 验证继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  
  // 确认子类声明了被遮蔽的方法
  derivedClass.declaredAttribute(_) = overriddenMethod and
  
  // 检查超类中是否存在遮蔽属性的赋值
  exists(FunctionObject baseClassInit, Attribute attributeNode |
    // 超类必须定义__init__方法
    baseClass.declaredAttribute("__init__") = baseClassInit and
    
    // 属性赋值发生在__init__方法的作用域内
    attributeAssignment.getScope() = baseClassInit.getOrigin().(FunctionExpr).getInnerScope() and
    
    // 赋值目标是self的属性
    attributeNode = attributeAssignment.getATarget() and
    attributeNode.getObject().(Name).getId() = "self" and
    
    // 属性名与子类方法名相同，造成遮蔽
    attributeNode.getName() = overriddenMethod.getName()
  ) and
  
  // 排除超类已定义同名方法的情况（此时不是遮蔽而是重写）
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 查询所有被超类属性遮蔽的子类方法
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
where method_shadowed_by_superclass_attribute(derivedClass, baseClass, attributeAssignment, overriddenMethod)
// 输出结果：被遮蔽方法的位置、描述信息、遮蔽属性的位置、属性类型标识
select overriddenMethod.getOrigin(),
  "Method '" + overriddenMethod.getName() + "' is shadowed by an $@ in superclass '" + baseClass.getName() +
    "'.", attributeAssignment, "attribute"