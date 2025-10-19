/**
 * @name Property in old-style class
 * @description Detects usage of property descriptors in old-style classes, which is non-functional since Python 2.1.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// 定义变量：propertyDescriptor表示属性对象，classDef表示类定义
from PropertyObject propertyDescriptor, ClassObject classDef
// 检查类是否声明了该属性
where classDef.declaredAttribute(_) = propertyDescriptor
  // 确保类推断没有失败
  and not classDef.failedInference()
  // 验证类是旧式类（非新式类）
  and not classDef.isNewStyle()
// 输出问题属性及描述信息
select propertyDescriptor,
  "Property " + propertyDescriptor.getName() + " will not work properly, as class " + classDef.getName() +
    " is an old-style class."