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

// 检查类是否包含少于两个公共方法（排除初始化方法）
predicate has_insufficient_public_methods(Class klass, int publicMethodCount) {
  (publicMethodCount = 0 or publicMethodCount = 1) and
  publicMethodCount = count(Function method |
    method = klass.getAMethod() and
    not method = klass.getInitMethod()
  )
}

// 检查类是否未定义任何特殊方法
predicate lacks_special_methods(Class klass) {
  not exists(Function method |
    method = klass.getAMethod() and
    method.isSpecialMethod()
  )
}

// 检查类是否没有继承关系（仅继承object）
predicate has_no_inheritance(Class klass) {
  // 验证类没有父类（除object外）
  not exists(ClassValue current, ClassValue parent |
    current.getScope() = klass and
    parent != ClassValue::object()
  |
    parent.getABaseType() = current or
    current.getABaseType() = parent
  ) and
  // 验证基类仅为object
  not exists(Expr baseExpr |
    baseExpr = klass.getABase() and
    (not baseExpr instanceof Name or baseExpr.(Name).getId() != "object")
  )
}

// 检查类是否被装饰器修饰
predicate is_decorated(Class klass) {
  exists(klass.getADecorator())
}

// 检查类是否维护状态（通过属性操作或特定方法调用）
predicate maintains_state(Class klass) {
  // 检查方法中是否存在属性存储操作
  exists(Function method, ExprContext context |
    method.getScope() = klass and
    (context instanceof Store or context instanceof AugStore)
  |
    exists(Subscript subscript |
      subscript.getScope() = method and
      subscript.getCtx() = context
    )
    or
    exists(Attribute attribute |
      attribute.getScope() = method and
      attribute.getCtx() = context
    )
  )
  // 检查方法中是否存在状态修改方法调用
  or
  exists(Function method, Call funcCall, Attribute attr, string methodName |
    method.getScope() = klass and
    funcCall.getScope() = method and
    funcCall.getFunc() = attr and
    attr.getName() = methodName
  |
    methodName in ["pop", "remove", "discard", "extend", "append"]
  )
}

// 综合判断类是否为无用类
predicate is_useless_class(Class klass, int publicMethodCount) {
  klass.isTopLevel() and
  klass.isPublic() and
  has_no_inheritance(klass) and
  has_insufficient_public_methods(klass, publicMethodCount) and
  lacks_special_methods(klass) and
  not klass.isProbableMixin() and
  not is_decorated(klass) and
  not maintains_state(klass)
}

// 查询无用类并生成诊断消息
from Class klass, int publicMethodCount, string diagnosticMessage
where
  is_useless_class(klass, publicMethodCount) and
  (
    publicMethodCount = 1 and
    diagnosticMessage =
      "Class " + klass.getName() +
        " defines only one public method, which should be replaced by a function."
    or
    publicMethodCount = 0 and
    diagnosticMessage =
      "Class " + klass.getName() +
        " defines no public methods and could be replaced with a namedtuple or dictionary."
  )
select klass, diagnosticMessage