/**
 * @name Superclass attribute shadows subclass method
 * @description 在继承层次结构中，当父类的 __init__ 方法中定义的实例属性与子类中定义的方法同名时，
 *              会发生属性遮蔽方法的问题。这会导致运行时行为异常，因为属性赋值会覆盖方法引用，
 *              使得子类方法无法被正常调用。
 * @kind problem
 * @problem.severity error
 * @tags maintainability
 *       correctness
 * @sub-severity low
 * @precision high
 * @id py/attribute-shadows-method
 */

/*
 * 检测逻辑说明：
 * 1. 建立类继承关系模型
 * 2. 定位子类中定义的方法成员
 * 3. 在父类初始化方法中查找同名属性赋值
 * 4. 排除父类显式定义同名方法的合理设计场景
 */

import python

// 检测方法被父类属性遮蔽的核心谓词
predicate methodShadowedBySuperAttr(
  ClassObject childClass, ClassObject parentClass, Assign attrAssign, FunctionObject shadowedFunc
) {
  // 确立继承关系：子类直接继承自父类
  childClass.getASuperType() = parentClass and
  
  // 确认子类声明了被遮蔽的方法
  childClass.declaredAttribute(_) = shadowedFunc and
  
  // 在父类初始化方法中定位同名属性赋值
  exists(FunctionObject initFunc, Attribute attr |
    // 父类必须定义__init__方法
    parentClass.declaredAttribute("__init__") = initFunc and
    
    // 属性赋值的目标是attr
    attr = attrAssign.getATarget() and
    
    // 属性赋值对象必须是self实例
    attr.getObject().(Name).getId() = "self" and
    
    // 属性名与子类方法名完全一致
    attr.getName() = shadowedFunc.getName() and
    
    // 赋值操作发生在父类初始化方法的作用域内
    attrAssign.getScope() = initFunc.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  
  // 排除父类显式定义同名方法的合理设计
  not parentClass.hasAttribute(shadowedFunc.getName())
}

// 主查询：输出被遮蔽的方法及其上下文信息
from ClassObject childClass, ClassObject parentClass, Assign attrAssign, FunctionObject shadowedFunc
where methodShadowedBySuperAttr(childClass, parentClass, attrAssign, shadowedFunc)
select shadowedFunc.getOrigin(),
  "Method " + shadowedFunc.getName() + " is shadowed by an $@ in super class '" + parentClass.getName() +
    "'.", attrAssign, "attribute"