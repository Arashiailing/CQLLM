/**
 * @name Superclass attribute shadows subclass method
 * @description 在继承体系中，若基类的属性与派生类的方法同名，则派生类的方法会被基类的属性所遮蔽。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 本查询检测派生类方法被基类属性遮蔽的情况
 * 重点分析基类__init__方法中通过self赋值定义的属性
 */

import python

// 定义谓词：判断派生类方法是否被基类属性遮蔽
predicate isMethodShadowedBySuperClassAttribute(
  ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject methodInSub
) {
  // 确认继承关系：subClass 继承自 superClass
  subClass.getASuperType() = superClass and
  // 派生类声明了 methodInSub 方法
  subClass.declaredAttribute(_) = methodInSub and
  // 检查基类初始化方法中存在同名属性赋值
  exists(FunctionObject superInitMethod, Attribute assignedAttr |
    // 基类定义了 __init__ 方法
    superClass.declaredAttribute("__init__") = superInitMethod and
    // 属性赋值目标是 assignedAttr
    assignedAttr = attrAssign.getATarget() and
    // 属性赋值对象是 self
    assignedAttr.getObject().(Name).getId() = "self" and
    // 属性名与派生类方法名相同
    assignedAttr.getName() = methodInSub.getName() and
    // 赋值操作发生在基类初始化方法中
    attrAssign.getScope() = superInitMethod.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  // 排除基类定义同名方法的情况（避免误报有意设计）
  not superClass.hasAttribute(methodInSub.getName())
}

// 查询被遮蔽的方法及其相关元素
from ClassObject subClass, ClassObject superClass, Assign attrAssign, FunctionObject methodInSub
// 应用谓词筛选目标案例
where isMethodShadowedBySuperClassAttribute(subClass, superClass, attrAssign, methodInSub)
// 选择被遮蔽方法位置、错误信息、属性赋值位置和类型标识
select methodInSub.getOrigin(),
  "Method " + methodInSub.getName() + " is shadowed by an $@ in super class '" + superClass.getName() +
    "'.", attrAssign, "attribute"