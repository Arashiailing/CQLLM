/**
 * @name Property in old-style class
 * @description Detects property descriptors inside old-style classes, which are not supported
 *              in Python 2.1 and later. This may cause unexpected behavior or runtime errors.
 * @kind problem
 * @id py/property-in-old-style-class
 * @tags portability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 */

import python

// 查找位于旧式类中的属性描述符
from PropertyObject propertyDescriptor, ClassObject enclosingClass
where
  // 验证属性描述符是类的直接成员
  enclosingClass.declaredAttribute(_) = propertyDescriptor and
  // 确保类定义能够被成功解析
  not enclosingClass.failedInference() and
  // 确认类为旧式类（未继承自object基类）
  not enclosingClass.isNewStyle()
// 生成检测结果并附带详细说明
select propertyDescriptor,
  "Property " + propertyDescriptor.getName() + " will not function correctly, as class " + enclosingClass.getName() +
    " is an old-style class."