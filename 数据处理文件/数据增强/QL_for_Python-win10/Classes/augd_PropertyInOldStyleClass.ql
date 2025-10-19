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

// 查找在旧式类中定义的属性对象
from PropertyObject propertyObj, ClassObject classObj
// 确保类对象成功推断且为旧式类
where 
  // 类对象声明了该属性
  classObj.declaredAttribute(_) = propertyObj and
  // 类对象推断成功
  not classObj.failedInference() and
  // 类对象是旧式类（非新式类）
  not classObj.isNewStyle()
// 生成警告信息，指出属性在旧式类中无法正常工作
select propertyObj,
  "Property " + propertyObj.getName() + " will not work properly, as class " + classObj.getName() +
    " is an old-style class."