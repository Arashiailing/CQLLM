/**
 * @name Property in old-style class
 * @description Using property descriptors in old-style classes does not work from Python 2.1 onward.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// 从PropertyObject和ClassObject中导入prop和cls变量
from PropertyObject prop, ClassObject cls
// 条件：cls声明了某个属性，并且该属性等于prop，同时cls没有失败的推断且不是新式类
where cls.declaredAttribute(_) = prop and not cls.failedInference() and not cls.isNewStyle()
// 选择符合条件的prop和生成的警告信息
select prop,
  "Property " + prop.getName() + " will not work properly, as class " + cls.getName() +
    " is an old-style class."
