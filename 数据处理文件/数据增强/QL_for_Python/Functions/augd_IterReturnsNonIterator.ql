/**
 * @name `__iter__` method returns a non-iterator
 * @description Finding classes that are returned by `__iter__` methods but do not implement the iterator interface.
 *              Such classes, when used in a 'for' loop, would raise a 'TypeError' because they lack the required
 *              `__next__` method.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-iterator
 */

import python

from ClassValue containerClass, FunctionValue iterMethod, ClassValue returnedType
where
  // 查找容器类中的 __iter__ 方法
  iterMethod = containerClass.lookup("__iter__") and
  // 获取 __iter__ 方法的推断返回类型
  returnedType = iterMethod.getAnInferredReturnType() and
  // 检查返回类型是否实现了迭代器接口
  not returnedType.isIterator()
select
  returnedType,
  "Class " + returnedType.getName() +
    " is returned as an iterator (by $@) but does not fully implement the iterator interface.",
  iterMethod, iterMethod.getName()