/**
 * @name Superclass attribute shadows subclass method
 * @description 检测超类中定义的属性是否遮蔽了子类中同名的方法定义
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 查询逻辑说明：
 * 本查询识别子类中被超类属性遮蔽的方法，具体条件包括：
 * 1. 存在继承关系的两个类（子类和超类）
 * 2. 子类声明了一个方法
 * 3. 超类在其__init__方法中定义了与子类方法同名的属性
 * 4. 超类本身没有定义同名的方法
 * 这种情况会导致子类方法被超类属性遮蔽，可能引起意外的行为
 */

import python

// 判断子类方法是否被超类属性遮蔽的谓词
predicate shadowed_by_super_class(
  ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
) {
  // 确立继承关系：derivedClass 继承自 baseClass
  derivedClass.getASuperType() = baseClass and
  
  // 确认子类声明了目标方法
  derivedClass.declaredAttribute(_) = overriddenMethod and
  
  // 验证超类在__init__中定义了同名属性
  exists(FunctionObject initializer |
    // 超类包含__init__方法
    baseClass.declaredAttribute("__init__") = initializer and
    
    // 检查__init__方法中的属性赋值
    exists(Attribute assignedAttribute |
      // 属性赋值语句的目标是self成员
      assignedAttribute = attributeAssignment.getATarget() and
      // 确保赋值对象是self实例
      assignedAttribute.getObject().(Name).getId() = "self" and
      // 属性名与子类方法名相同
      assignedAttribute.getName() = overriddenMethod.getName() and
      // 赋值发生在超类__init__作用域内
      attributeAssignment.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope()
    )
  ) and
  
  // 排除超类已定义同名方法的情况
  not baseClass.hasAttribute(overriddenMethod.getName())
}

// 查询被遮蔽的方法及其相关元素
from ClassObject derivedClass, ClassObject baseClass, Assign attributeAssignment, FunctionObject overriddenMethod
// 应用遮蔽检测谓词
where shadowed_by_super_class(derivedClass, baseClass, attributeAssignment, overriddenMethod)
// 输出结果：方法位置、描述信息、属性赋值位置和类型标签
select overriddenMethod.getOrigin(),
  "Method '" + overriddenMethod.getName() + "' is shadowed by $@ in superclass '" + baseClass.getName() + 
    "'.", attributeAssignment, "attribute definition"