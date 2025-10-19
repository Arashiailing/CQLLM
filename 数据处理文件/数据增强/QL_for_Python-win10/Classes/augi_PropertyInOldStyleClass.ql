/**
 * @name Property in old-style class
 * @description Identifies properties defined in old-style classes, which are incompatible 
 *              with Python's property descriptor mechanism from version 2.1 onwards.
 * @kind problem
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/property-in-old-style-class
 */

import python

// 查找所有属性对象和类对象的组合
from PropertyObject propertyObj, ClassObject classObj
// 筛选条件1：属性被类声明
where classObj.declaredAttribute(_) = propertyObj
  // 筛选条件2：类的推断没有失败
  and not classObj.failedInference()
  // 筛选条件3：类是旧式类（非新式类）
  and not classObj.isNewStyle()
// 输出属性对象和相应的警告信息
select propertyObj,
  "Property " + propertyObj.getName() + " will not work properly, as class " + classObj.getName() +
    " is an old-style class."