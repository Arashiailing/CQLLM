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
 * 识别子类中被超类属性遮蔽的方法：
 * 1. 子类声明了方法
 * 2. 超类在__init__中定义了同名属性
 * 3. 超类未定义同名方法
 */

import python

// 判断子类方法是否被超类属性遮蔽的谓词
predicate shadowed_by_super_class(
  ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMethod
) {
  // 建立子类与超类的继承关系
  subCls.getASuperType() = superCls and
  // 确认子类声明了目标方法
  subCls.declaredAttribute(_) = shadowedMethod and
  // 验证超类__init__中的属性定义
  exists(FunctionObject initMethod, Attribute targetAttr |
    // 超类包含__init__方法
    superCls.declaredAttribute("__init__") = initMethod and
    // 属性赋值语句的目标是self成员
    targetAttr = attrAssign.getATarget() and
    // 确保赋值对象是self实例
    targetAttr.getObject().(Name).getId() = "self" and
    // 属性名与子类方法名相同
    targetAttr.getName() = shadowedMethod.getName() and
    // 赋值发生在超类__init__作用域内
    attrAssign.getScope() = initMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除超类已定义同名方法的情况
  not superCls.hasAttribute(shadowedMethod.getName())
}

// 查询被遮蔽的方法及其相关元素
from ClassObject subCls, ClassObject superCls, Assign attrAssign, FunctionObject shadowedMethod
// 应用遮蔽检测谓词
where shadowed_by_super_class(subCls, superCls, attrAssign, shadowedMethod)
// 输出结果：方法位置、描述信息、属性赋值位置和类型标签
select shadowedMethod.getOrigin(),
  "Method '" + shadowedMethod.getName() + "' is shadowed by $@ in superclass '" + superCls.getName() + 
    "'.", attrAssign, "attribute definition"