/**
 * @name Superclass attribute shadows subclass method
 * @description 定义在超类方法中的一个属性，其名称与子类方法匹配，会隐藏子类的方法。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-subclass-method
 */

/*
 * 检测子类方法是否被超类属性遮蔽的情况
 */

import python

/**
 * 检测方法遮蔽情况：子类方法被超类属性遮蔽
 */
predicate shadowed_by_super_class(
  ClassObject childClass, ClassObject parentClass, Assign attrAssignNode, FunctionObject shadowedMethod
) {
  // 建立继承关系：子类继承自超类
  childClass.getASuperType() = parentClass and
  
  // 确认子类声明了被遮蔽的方法
  childClass.declaredAttribute(_) = shadowedMethod and
  
  // 在超类__init__方法中查找匹配的属性赋值
  exists(FunctionObject initializer, Attribute targetAttr |
    // 超类声明了__init__初始化方法
    parentClass.declaredAttribute("__init__") = initializer and
    
    // 属性赋值节点目标为属性节点
    targetAttr = attrAssignNode.getATarget() and
    
    // 属性属于self对象
    targetAttr.getObject().(Name).getId() = "self" and
    
    // 属性名与子类方法名相同（核心遮蔽条件）
    targetAttr.getName() = shadowedMethod.getName() and
    
    // 赋值发生在__init__方法的作用域内
    attrAssignNode.getScope() = initializer.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 确保超类未定义同名方法（避免误报）
  not parentClass.hasAttribute(shadowedMethod.getName())
}

// 查询满足遮蔽条件的代码元素
from ClassObject childClass, ClassObject parentClass, Assign attrAssignNode, FunctionObject shadowedMethod
// 应用遮蔽条件谓词进行过滤
where shadowed_by_super_class(childClass, parentClass, attrAssignNode, shadowedMethod)
// 生成检测结果：方法位置、错误信息、属性赋值位置和类型标注
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is shadowed by an $@ in superclass '" + parentClass.getName() +
    "'.", attrAssignNode, "attribute"