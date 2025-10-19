/**
 * @name Non-standard exception raised in special method
 * @description Raising a non-standard exception in a special method alters the expected interface of that method.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 * @problem.severity recommendation
 * @sub-severity high
 * @precision very-high
 * @id py/unexpected-raise-in-special-method
 */

import python

// 私有谓词，用于判断方法名是否为属性相关的方法
private predicate attribute_method(string name) {
  // 检查方法名是否为 "__getattribute__", "__getattr__" 或 "__setattr__"
  name = "__getattribute__" or name = "__getattr__" or name = "__setattr__"
}

// 私有谓词，用于判断方法名是否为索引相关的方法
private predicate indexing_method(string name) {
  // 检查方法名是否为 "__getitem__", "__setitem__" 或 "__delitem__"
  name = "__getitem__" or name = "__setitem__" or name = "__delitem__"
}

// 私有谓词，用于判断方法名是否为算术运算相关的方法
private predicate arithmetic_method(string name) {
  // 检查方法名是否在算术运算方法列表中
  name in [
      "__add__", "__sub__", "__or__", "__xor__", "__rshift__", "__pow__", "__mul__", "__neg__",
      "__radd__", "__rsub__", "__rdiv__", "__rfloordiv__", "__div__", "__rdiv__", "__rlshift__",
      "__rand__", "__ror__", "__rxor__", "__rrshift__", "__rpow__", "__rmul__", "__truediv__",
      "__rtruediv__", "__pos__", "__iadd__", "__isub__", "__idiv__", "__ifloordiv__", "__idiv__",
      "__ilshift__", "__iand__", "__ior__", "__ixor__", "__irshift__", "__abs__", "__ipow__",
      "__imul__", "__itruediv__", "__floordiv__", "__div__", "__divmod__", "__lshift__", "__and__"
    ]
}

// 私有谓词，用于判断方法名是否为排序相关的方法
private predicate ordering_method(string name) {
  // 检查方法名是否为 "__lt__", "__le__", "__gt__", "__ge__" 或 (Python 2 中的 "__cmp__")
  name = "__lt__"
  or
  name = "__le__"
  or
  name = "__gt__"
  or
  name = "__ge__"
  or
  name = "__cmp__" and major_version() = 2
}

// 私有谓词，用于判断方法名是否为类型转换相关的方法
private predicate cast_method(string name) {
  // 检查方法名是否为 Python 2 中的 "__nonzero__" 或类型转换方法如 "__int__", "__float__" 等
  name = "__nonzero__" and major_version() = 2
  or
  name = "__int__"
  or
  name = "__float__"
  or
  name = "__long__"
  or
  name = "__trunc__"
  or
  name = "__complex__"
}

// 谓词，用于判断异常抛出是否符合预期
predicate correct_raise(string name, ClassObject ex) {
  // 如果抛出的异常类型是 TypeError，并且方法名是特殊方法之一，或者符合 preferred_raise 规则
  ex.getAnImproperSuperType() = theTypeErrorType() and
  (
    name = "__copy__" or
    name = "__deepcopy__" or
    name = "__call__" or
    indexing_method(name) or
    attribute_method(name)
  )
  or
  preferred_raise(name, ex)
  or
  preferred_raise(name, ex.getASuperType())
}

// 谓词，用于判断异常抛出是否符合推荐的类型
predicate preferred_raise(string name, ClassObject ex) {
  // 如果方法名是属性相关方法且抛出的异常类型是 AttributeError，或者符合其他特定组合
  attribute_method(name) and ex = theAttributeErrorType()
  or
  indexing_method(name) and ex = Object::builtin("LookupError")
  or
  ordering_method(name) and ex = theTypeErrorType()
  or
  arithmetic_method(name) and ex = Object::builtin("ArithmeticError")
  or
  name = "__bool__" and ex = theTypeErrorType()
}

// 谓词，用于判断某些情况下不需要抛出异常
predicate no_need_to_raise(string name, string message) {
  // 如果方法名是 "__hash__" 且消息是建议使用 __hash__ = None，或者方法是类型转换方法且无需实现
  name = "__hash__" and message = "use __hash__ = None instead"
  or
  cast_method(name) and message = "there is no need to implement the method at all."
}

// 谓词，用于判断函数是否是抽象函数
predicate is_abstract(FunctionObject func) {
  // 如果函数有装饰器且装饰器名称匹配 "abstract"
  func.getFunction().getADecorator().(Name).getId().matches("%abstract%")
}

// 谓词，用于判断函数是否总是抛出特定异常
predicate always_raises(FunctionObject f, ClassObject ex) {
  // 如果函数总是抛出 ex 类型的异常，且没有正常退出路径，且不是 StopIteration 异常
  ex = f.getARaisedType() and
  strictcount(f.getARaisedType()) = 1 and
  not exists(f.getFunction().getANormalExit()) and
  /* raising StopIteration is equivalent to a return in a generator */
  not ex = theStopIterationType()
}

// 查询语句，选择总是抛出非标准异常的特殊方法，并给出建议信息
from FunctionObject f, ClassObject cls, string message
where
  // 筛选条件：函数是特殊方法，不是抽象函数，总是抛出异常，且不符合正确抛出规则或无需抛出异常的情况
  f.getFunction().isSpecialMethod() and
  not is_abstract(f) and
  always_raises(f, cls) and
  (
    no_need_to_raise(f.getName(), message) and not cls.getName() = "NotImplementedError"
    or
    not correct_raise(f.getName(), cls) and
    not cls.getName() = "NotImplementedError" and
    exists(ClassObject preferred | preferred_raise(f.getName(), preferred) |
      message = "raise " + preferred.getName() + " instead"
    )
  )
select f, "Function always raises $@; " + message, cls, cls.toString()
