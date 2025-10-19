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
 * 检测子类方法是否被超类属性遮蔽的情况
 */

import python

// 定义谓词检测方法遮蔽情况：子类方法被超类属性遮蔽
predicate shadowed_by_super_class(
  ClassObject subclass, ClassObject superclass, Assign attrAssignment, FunctionObject shadowedMethod
) {
  // 1. 建立继承关系：subclass继承自superclass
  subclass.getASuperType() = superclass and
  // 2. 确认子类声明了被遮蔽的方法
  subclass.declaredAttribute(_) = shadowedMethod and
  // 3. 检查超类__init__方法中的属性赋值
  exists(FunctionObject initMethod, Attribute assignedAttr |
    // 3.1 超类声明了__init__方法
    superclass.declaredAttribute("__init__") = initMethod and
    // 3.2 赋值目标是一个属性节点
    assignedAttr = attrAssignment.getATarget() and
    // 3.3 该属性属于self对象
    assignedAttr.getObject().(Name).getId() = "self" and
    // 3.4 属性名与子类方法名相同
    assignedAttr.getName() = shadowedMethod.getName() and
    // 3.5 赋值发生在__init__方法的作用域内
    attrAssignment.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 4. 确保超类没有定义同名方法（避免误报）
  not superclass.hasAttribute(shadowedMethod.getName())
}

// 查询满足遮蔽条件的代码元素
from ClassObject subclass, ClassObject superclass, Assign attrAssignment, FunctionObject shadowedMethod
// 应用遮蔽条件谓词进行过滤
where shadowed_by_super_class(subclass, superclass, attrAssignment, shadowedMethod)
// 生成检测结果：方法位置、错误信息、属性赋值位置和类型标注
select shadowedMethod.getOrigin(),
  "Method " + shadowedMethod.getName() + " is shadowed by an $@ in super class '" + superclass.getName() +
    "'.", attrAssignment, "attribute"