/**
 * @name `__iter__` method returns a non-iterator
 * @description The `__iter__` method returns a non-iterator which, if used in a 'for' loop, would raise a 'TypeError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python  # 导入python模块，用于处理Python代码的静态分析

from ClassValue iterable, FunctionValue iter, ClassValue iterator  # 从ClassValue和FunctionValue中引入iterable、iter和iterator
where
  iter = iterable.lookup("__iter__") and  # 查找iterable类中的`__iter__`方法，并将其赋值给变量iter
  iterator = iter.getAnInferredReturnType() and  # 获取`__iter__`方法的推断返回类型，并将其赋值给变量iterator
  not iterator.isIterator()  # 检查iterator是否实现了迭代器接口，如果没有实现则继续执行
select iterator,  # 选择iterator作为查询结果的一部分
  "Class " + iterator.getName() +  # 构建错误信息字符串，包含未实现迭代器接口的类名
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",  # 完成错误信息字符串
  iter, iter.getName()  # 选择iter及其名称作为查询结果的一部分
