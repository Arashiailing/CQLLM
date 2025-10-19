/**
 * @name 错误的类实例化参数数量
 * @description 在调用类的 `__init__` 方法时，使用过多或过少的参数将导致运行时出现 TypeError。
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-number-class-arguments
 */

import python
import Expressions.CallArgs

from Call call, ClassValue cls, string too, string should, int limit, FunctionValue init
where
  (
    // 检查是否传递了过多的参数
    too_many_args(call, cls, limit) and
    too = "too many arguments" and
    should = "no more than "
    or
    // 检查是否传递了过少的参数
    too_few_args(call, cls, limit) and
    too = "too few arguments" and
    should = "no fewer than "
  ) and
  // 获取类的构造函数或初始化方法
  init = get_function_or_initializer(cls)
select call, "Call to $@ with " + too + "; should be " + should + limit.toString() + ".", init,
  // 选择调用、错误信息和初始化方法的名称
  init.getQualifiedName()
