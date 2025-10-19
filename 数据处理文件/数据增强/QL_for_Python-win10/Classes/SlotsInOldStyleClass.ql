/**
 * @name `__slots__` in old-style class
 * @description Overriding the class dictionary by declaring `__slots__` is not supported by old-style
 *              classes.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python  # 导入Python库，用于访问Python代码中的元素

from ClassObject c  # 从ClassObject类中选择对象c
where not c.isNewStyle() and c.declaresAttribute("__slots__") and not c.failedInference() 
# 条件：c不是新式类，并且声明了`__slots__`属性，同时没有推断失败
select c,  # 选择符合条件的类对象c
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'." 
  # 提示信息：在旧式类中使用`__slots__`只会创建一个名为`__slots__`的类属性。
