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

// 查找在旧式类中定义的属性对象
from PropertyObject propObj, ClassObject oldStyleClass
where
  // 验证属性确实在该类中声明
  oldStyleClass.declaredAttribute(_) = propObj and
  // 确保类的类型推断成功，避免误报
  not oldStyleClass.failedInference() and
  // 确认类是旧式类（未继承自object或新式类）
  not oldStyleClass.isNewStyle()
// 输出问题属性及其错误描述
select propObj,
  "Property " + propObj.getName() + " will not work properly, as class " + oldStyleClass.getName() +
    " is an old-style class."