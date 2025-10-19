/**
 * @name `__slots__` in old-style class
 * @description Declaring `__slots__` in old-style classes does not override the instance dictionary 
 *              as intended, instead creating a regular class attribute.
 * @kind problem
 * @problem.severity error
 * @tags portability
 *       correctness
 * @sub-severity low
 * @precision very-high
 * @id py/slots-in-old-style-class
 */

import python

from ClassObject targetClass
where
  // 识别非新式类（Python 2.x 风格类）
  not targetClass.isNewStyle() 
  and 
  // 检测显式声明的 __slots__ 属性
  targetClass.declaresAttribute("__slots__")
  and 
  // 确保类分析成功（避免误报）
  not targetClass.failedInference()
select 
  targetClass,
  "Using '__slots__' in an old style class just creates a class attribute called '__slots__'."