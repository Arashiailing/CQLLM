/**
 * @name `__iter__` method returns a non-iterator
 * @description Detects classes whose `__iter__` method returns a non-iterator object.
 *              Such objects would raise a 'TypeError' when used in a 'for' loop.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python  // 导入Python静态分析模块

// 定义变量：目标类、其__iter__方法以及该方法的返回类型
from ClassValue targetClass, FunctionValue iterMethod, ClassValue returnType
where
  // 查找目标类中的__iter__方法
  iterMethod = targetClass.lookup("__iter__") and
  // 获取__iter__方法的推断返回类型
  returnType = iterMethod.getAnInferredReturnType() and
  // 验证返回类型未实现迭代器接口
  not returnType.isIterator()
select returnType,  // 选择返回类型作为主要结果
  // 构建错误信息：指出返回的类未实现迭代器接口
  "Class " + returnType.getName() + 
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()  // 提供违规方法及其名称作为上下文