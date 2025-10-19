/**
 * @name Special method has incorrect signature
 * @description Special method has incorrect signature
 * @kind problem
 * @tags reliability
 *       correctness
 *       quality
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/special-method-wrong-signature
 */

import python  // 导入Python库，用于分析Python代码
import semmle.python.dataflow.new.internal.DataFlowDispatch as DD  // 导入数据流调度模块，并命名为DD

// 判断是否为一元操作符的方法
predicate is_unary_op(string name) {
  name in [
      "__del__", "__repr__", "__neg__", "__pos__", "__abs__", "__invert__", "__complex__",
      "__int__", "__float__", "__long__", "__oct__", "__hex__", "__str__", "__index__", "__enter__",
      "__hash__", "__bool__", "__nonzero__", "__unicode__", "__len__", "__iter__", "__reversed__",
      "__aenter__", "__aiter__", "__anext__", "__await__", "__ceil__", "__floor__", "__trunc__",
      "__length_hint__", "__dir__", "__bytes__"
    ]
}

// 判断是否为二元操作符的方法
predicate is_binary_op(string name) {
  name in [
      "__lt__", "__le__", "__delattr__", "__delete__", "__instancecheck__", "__subclasscheck__",
      "__getitem__", "__delitem__", "__contains__", "__add__", "__sub__", "__mul__", "__eq__",
      "__floordiv__", "__div__", "__truediv__", "__mod__", "__divmod__", "__lshift__", "__rshift__",
      "__and__", "__xor__", "__or__", "__ne__", "__radd__", "__rsub__", "__rmul__", "__rfloordiv__",
      "__rdiv__", "__rtruediv__", "__rmod__", "__rdivmod__", "__rpow__", "__rlshift__", "__gt__",
      "__rrshift__", "__rand__", "__rxor__", "__ror__", "__iadd__", "__isub__", "__imul__",
      "__ifloordiv__", "__idiv__", "__itruediv__", "__ge__", "__imod__", "__ipow__", "__ilshift__",
      "__irshift__", "__iand__", "__ixor__", "__ior__", "__coerce__", "__cmp__", "__rcmp__",
      "__getattr__", "__getattribute__", "__buffer__", "__release_buffer__", "__matmul__",
      "__rmatmul__", "__imatmul__", "__missing__", "__class_getitem__", "__mro_entries__",
      "__format__"
    ]
}

// 判断是否为三元操作符的方法
predicate is_ternary_op(string name) {
  name in ["__setattr__", "__set__", "__setitem__", "__getslice__", "__delslice__", "__set_name__"]
}

// 判断是否为四元操作符的方法
predicate is_quad_op(string name) { name in ["__setslice__", "__exit__", "__aexit__"] }

// 获取参数数量的方法
int argument_count(string name) {
  is_unary_op(name) and result = 1  // 如果是一元操作符，返回1
  or
  is_binary_op(name) and result = 2  // 如果是二元操作符，返回2
  or
  is_ternary_op(name) and result = 3  // 如果是三元操作符，返回3
  or
  is_quad_op(name) and result = 4  // 如果是四元操作符，返回4
}

/**
 * 如果`func`是静态方法，则返回1，否则返回0。这个谓词用于调整特殊方法的预期参数数量。
 */
int staticmethod_correction(Function func) {
  if DD::isStaticmethod(func) then result = 1 else result = 0  // 检查是否是静态方法，并返回相应的值
}

// 定义不正确的特殊方法定义的谓词
predicate incorrect_special_method_defn(
  Function func, string message, boolean show_counts, string name, boolean is_unused_default
) {
  exists(int required, int correction |
    required = argument_count(name) - correction and correction = staticmethod_correction(func)
  |
    /* actual_non_default <= actual */
    if required > func.getMaxPositionalArguments()
    then message = "Too few parameters" and show_counts = true and is_unused_default = false  // 如果参数太少，设置消息和标志
    else
      if required < func.getMinPositionalArguments()
      then message = "Too many parameters" and show_counts = true and is_unused_default = false  // 如果参数太多，设置消息和标志
      else (
        func.getMinPositionalArguments() < required and
        not func.hasVarArg() and
        message =
          (required - func.getMinPositionalArguments()) + " default value(s) will never be used" and
        show_counts = false and
        is_unused_default = true  // 如果默认值不会被使用，设置消息和标志
      )
  )
}

// 定义不正确的幂运算方法的谓词
predicate incorrect_pow(
  Function func, string message, boolean show_counts, boolean is_unused_default
) {
  exists(int correction | correction = staticmethod_correction(func) |
    func.getMaxPositionalArguments() < 2 - correction and
    message = "Too few parameters" and
    show_counts = true and
    is_unused_default = false  // 如果参数太少，设置消息和标志
    or
    func.getMinPositionalArguments() > 3 - correction and
    message = "Too many parameters" and
    show_counts = true and
    is_unused_default = false  // 如果参数太多，设置消息和标志
    or
    func.getMinPositionalArguments() < 2 - correction and
    message = (2 - func.getMinPositionalArguments()) + " default value(s) will never be used" and
    show_counts = false and
    is_unused_default = true  // 如果默认值不会被使用，设置消息和标志
    or
    func.getMinPositionalArguments() = 3 - correction and
    message = "Third parameter to __pow__ should have a default value" and
    show_counts = false and
    is_unused_default = false  // 如果第三个参数应该有默认值但没有，设置消息和标志
  )
}

// 定义不正确的取整方法的谓词
predicate incorrect_round(
  Function func, string message, boolean show_counts, boolean is_unused_default
) {
  exists(int correction | correction = staticmethod_correction(func) |
    func.getMaxPositionalArguments() < 1 - correction and
    message = "Too few parameters" and
    show_counts = true and
    is_unused_default = false  // 如果参数太少，设置消息和标志
    or
    func.getMinPositionalArguments() > 2 - correction and
    message = "Too many parameters" and
    show_counts = true and
    is_unused_default = false  // 如果参数太多，设置消息和标志
    or
    func.getMinPositionalArguments() = 2 - correction and
    message = "Second parameter to __round__ should have a default value" and
    show_counts = false and
    is_unused_default = false  // 如果第二个参数应该有默认值但没有，设置消息和标志
  )
}

// 定义不正确的获取方法的谓词
predicate incorrect_get(
  Function func, string message, boolean show_counts, boolean is_unused_default
) {
  exists(int correction | correction = staticmethod_correction(func) |
    func.getMaxPositionalArguments() < 3 - correction and
    message = "Too few parameters" and
    show_counts = true and
    is_unused_default = false  // 如果参数太少，设置消息和标志
    or
    func.getMinPositionalArguments() > 3 - correction and
    message = "Too many parameters" and
    show_counts = true and
    is_unused_default = false  // 如果参数太多，设置消息和标志
    or
    func.getMinPositionalArguments() < 2 - correction and
    not func.hasVarArg() and
    message = (2 - func.getMinPositionalArguments()) + " default value(s) will never be used" and
    show_counts = false and
    is_unused_default = true  // 如果默认值不会被使用，设置消息和标志
  )
}

// 返回应该具有的参数数量的字符串表示
string should_have_parameters(string name) {
  if name in ["__pow__", "__get__"]
  then result = "2 or 3"  // 如果方法是幂运算或获取方法，返回“2或3”个参数
  else result = argument_count(name).toString()  // 否则返回参数数量的字符串表示
}

// 返回实际具有的参数数量的字符串表示
string has_parameters(Function f) {
  exists(int i | i = f.getMinPositionalArguments() |
    i = 0 and result = "no parameters"  // 如果参数数量为0，返回“无参数”
    or
    i = 1 and result = "1 parameter"  // 如果参数数量为1，返回“1个参数”
    or
    i > 1 and result = i.toString() + " parameters"  // 如果参数数量大于1，返回参数数量的字符串表示
  )
}

/** 如果`f`可能是一个占位符函数，则保持为真，因此不足以报告。 */
predicate isLikelyPlaceholderFunction(Function f) {
  // Body has only a single statement.  // 如果函数体只有一个语句，则可能是占位符函数
  f.getBody().getItem(0) = f.getBody().getLastItem() and
  (
    // Body is a string literal. This is a common pattern for Zope interfaces.  // 如果函数体是一个字符串字面量，常见于Zope接口模式中，则可能是占位符函数
    f.getBody().getLastItem().(ExprStmt).getValue() instanceof StringLiteral
    or
    // Body just raises an exception.  // 如果函数体只是引发异常，则可能是占位符函数
    f.getBody().getLastItem() instanceof Raise
    or
    // Body is a pass statement.  // 如果函数体是一个pass语句，则可能是占位符函数
    f.getBody().getLastItem() instanceof Pass
  )
}

from
  Function f, string message, string sizes, boolean show_counts, string name, Class owner,
  boolean show_unused_defaults
where
  owner.getAMethod() = f and  // 确保函数属于某个类的方法
  f.getName() = name and  // 确保函数名匹配指定的名称
  (
    incorrect_special_method_defn(f, message, show_counts, name, show_unused_defaults)  // 如果函数定义不正确，则选择该函数
    or
    incorrect_pow(f, message, show_counts, show_unused_defaults) and name = "__pow__"  // 如果幂运算方法定义不正确，则选择该函数
    or
    incorrect_get(f, message, show_counts, show_unused_defaults) and name = "__get__"  // 如果获取方法定义不正确，则选择该函数
    or
    incorrect_round(f, message, show_counts, show_unused_defaults) and name = "__round__"  // 如果取整方法定义不正确，则选择该函数
  ) and
  not isLikelyPlaceholderFunction(f) and  // 确保函数不是占位符函数
  show_unused_defaults = false and  // 确保不显示未使用的默认值信息
  (
    show_counts = false and sizes = ""  // 如果不需要显示参数计数，则sizes为空字符串
    or
    show_counts = true and sizes = ", which has " + has_parameters(f) + ", but should have " + should_have_parameters(name)  // 如果需要显示参数计数，则生成相应的字符串表示
  )
select f, message + " for special method " + name + sizes + ", in class $@.", owner, owner.getName()  // 选择函数、消息、类及其名称进行报告输出
