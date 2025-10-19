/**
 * @name 错误的函数调用参数数量
 * @description 在函数调用中使用过多或过少的参数将导致运行时出现TypeError。
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-arguments
 */

import python  // 导入Python库，用于处理Python代码
import CallArgs  // 导入CallArgs库，用于处理函数调用参数

// 从Call、FunctionValue和字符串中选择数据，并定义变量too、should和limit
from Call call, FunctionValue func, string too, string should, int limit
where
  (
    // 如果调用的参数过多，设置too为"too many arguments"，should为"no more than "
    too_many_args(call, func, limit) and too = "too many arguments" and should = "no more than "
    or
    // 如果调用的参数过少，设置too为"too few arguments"，should为"no fewer than "
    too_few_args(call, func, limit) and too = "too few arguments" and should = "no fewer than "
  ) and
  // 排除抽象函数
  not isAbstract(func) and
  // 排除被重写的方法，如果重写的方法有正确的参数数量
  not exists(FunctionValue overridden |
    func.overrides(overridden) and correct_args_if_called_as_method(call, overridden)
  ) and
  /* `__new__`方法的语义可能有些微妙，所以我们简单地排除`__new__`方法 */
  // 排除名称为"__new__"的方法
  not func.getName() = "__new__"
select call, "Call to $@ with " + too + "; should be " + should + limit.toString() + ".", func,
  // 选择调用、错误信息、函数及其描述性字符串
  func.descriptiveString()
