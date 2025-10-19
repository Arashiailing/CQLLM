/**
 * @name Extents of classes
 * @description Identifies the location and extent of all classes in the codebase.
 * @kind extent
 * @id py/class-extents
 * @metricType reftype
 */

import python

// 检索代码库中定义的所有类
from Class definedClass
// 返回每个类的位置信息和类实例
select definedClass.getLocation(), definedClass