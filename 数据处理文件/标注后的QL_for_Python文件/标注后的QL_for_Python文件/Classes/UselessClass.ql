/**
 * @name Useless class
 * @description Class only defines one public method (apart from `__init__` or `__new__`) and should be replaced by a function
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity recommendation
 * @sub-severity low
 * @precision medium
 * @id py/useless-class
 */

import python

// 判断类是否少于两个公共方法的谓词函数
predicate fewer_than_two_public_methods(Class cls, int methods) {
  // 方法数为0或1，并且计算类中非初始化方法的数量
  (methods = 0 or methods = 1) and
  methods = count(Function f | f = cls.getAMethod() and not f = cls.getInitMethod())
}

// 判断类是否没有定义特殊方法的谓词函数
predicate does_not_define_special_method(Class cls) {
  // 检查是否存在特殊方法
  not exists(Function f | f = cls.getAMethod() and f.isSpecialMethod())
}

// 判断类是否没有继承关系的谓词函数
predicate no_inheritance(Class c) {
  // 检查类是否有父类（除了object）
  not exists(ClassValue cls, ClassValue other |
    cls.getScope() = c and
    other != ClassValue::object()
  |
    other.getABaseType() = cls or
    cls.getABaseType() = other
  ) and
  // 检查类的基类是否是object
  not exists(Expr base | base = c.getABase() |
    not base instanceof Name or base.(Name).getId() != "object"
  )
}

// 判断类是否被装饰的谓词函数
predicate is_decorated(Class c) { exists(c.getADecorator()) }

// 判断类是否是有状态的谓词函数
predicate is_stateful(Class c) {
  // 检查类的方法中是否有存储上下文或增广存储上下文
  exists(Function method, ExprContext ctx |
    method.getScope() = c and
    (ctx instanceof Store or ctx instanceof AugStore)
  |
    exists(Subscript s | s.getScope() = method and s.getCtx() = ctx)
    or
    exists(Attribute a | a.getScope() = method and a.getCtx() = ctx)
  )
  // 或者检查类的方法中是否有特定名称的调用
  or
  exists(Function method, Call call, Attribute a, string name |
    method.getScope() = c and
    call.getScope() = method and
    call.getFunc() = a and
    a.getName() = name
  |
    name in ["pop", "remove", "discard", "extend", "append"]
  )
}

// 判断类是否是无用类的谓词函数
predicate useless_class(Class c, int methods) {
  // 检查类是否是顶层类、公共类、无继承关系、少于两个公共方法、不定义特殊方法、不是可能的混入类、没有被装饰且不是有状态的类
  c.isTopLevel() and
  c.isPublic() and
  no_inheritance(c) and
  fewer_than_two_public_methods(c, methods) and
  does_not_define_special_method(c) and
  not c.isProbableMixin() and
  not is_decorated(c) and
  not is_stateful(c)
}

// 查询无用类并生成相应的消息
from Class c, int methods, string msg
where
  // 检查类是否是无用类
  useless_class(c, methods) and
  (
    // 如果类只有一个公共方法，生成相应的消息
    methods = 1 and
    msg =
      "Class " + c.getName() +
        " defines only one public method, which should be replaced by a function."
    or
    // 如果类没有公共方法，生成相应的消息
    methods = 0 and
    msg =
      "Class " + c.getName() +
        " defines no public methods and could be replaced with a namedtuple or dictionary."
  )
select c, msg
