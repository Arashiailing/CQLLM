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
 * 确定一个类是否定义了一个被超类中定义的属性所遮蔽的方法
 */

/* 需要找到在超类中定义的属性（仅在__init__中？） */
import python

// 定义谓词 shadowed_by_super_class，用于判断一个类的方法是否被超类的属性遮蔽
predicate shadowed_by_super_class(
  ClassObject c, ClassObject supercls, Assign assign, FunctionObject f
) {
  // 检查当前类的超类是否是指定的超类
  c.getASuperType() = supercls and
  // 检查当前类是否声明了指定的函数对象作为属性
  c.declaredAttribute(_) = f and
  // 存在一个初始化函数和属性，满足以下条件：
  exists(FunctionObject init, Attribute attr |
    // 超类声明了__init__属性，并且该属性是初始化函数
    supercls.declaredAttribute("__init__") = init and
    // 属性是赋值的目标
    attr = assign.getATarget() and
    // 属性的对象是一个名称为"self"的名称对象
    attr.getObject().(Name).getId() = "self" and
    // 属性的名称与函数对象的名称相同
    attr.getName() = f.getName() and
    // 赋值的作用域是初始化函数表达式的内部作用域
    assign.getScope() = init.getOrigin().(FunctionExpr).getInnerScope()
  ) and
  /*
   * 如果超类也定义了该方法，则没有问题。
   * 我们假设原始方法的定义是有原因的。
   */
  // 超类没有该属性
  not supercls.hasAttribute(f.getName())
}

// 从类对象、超类对象、赋值和函数对象中选择数据
from ClassObject c, ClassObject supercls, Assign assign, FunctionObject shadowed
// 使用谓词 shadowed_by_super_class 进行过滤
where shadowed_by_super_class(c, supercls, assign, shadowed)
// 选择被遮蔽的方法的原始位置、错误信息、赋值和属性类型
select shadowed.getOrigin(),
  "Method " + shadowed.getName() + " is shadowed by an $@ in super class '" + supercls.getName() +
    "'.", assign, "attribute"
