/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes where the `__iter__` method returns a non-iterator object.
 *              Such classes would raise a 'TypeError' when used in a 'for' loop.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python  // 导入python模块，用于处理Python代码的静态分析

from ClassValue targetClass, FunctionValue iterMethod, ClassValue returnedType  // 从ClassValue和FunctionValue中引入targetClass、iterMethod和returnedType
where
  // 在目标类中查找__iter__方法
  iterMethod = targetClass.lookup("__iter__") and  // 查找targetClass类中的`__iter__`方法，并将其赋值给变量iterMethod
  // 获取__iter__方法的推断返回类型
  returnedType = iterMethod.getAnInferredReturnType() and  // 获取`__iter__`方法的推断返回类型，并将其赋值给变量returnedType
  // 检查返回类型是否未实现迭代器接口
  not returnedType.isIterator()  // 检查returnedType是否实现了迭代器接口，如果没有实现则继续执行
select returnedType,  // 选择returnedType作为查询结果的一部分
  "Class " + returnedType.getName() +  // 构建错误信息字符串，包含未实现迭代器接口的类名
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",  // 完成错误信息字符串
  iterMethod, iterMethod.getName()  // 选择iterMethod及其名称作为查询结果的一部分