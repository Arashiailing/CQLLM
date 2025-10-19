/**
 * @name Extents of classes
 * @description Identifies the location and extent of all classes in the codebase.
 * @kind extent
 * @id py/class-extents
 * @metricType reftype
 */

import python

// 查询所有类的范围信息
from Class classExtent
// 选择类的位置信息和类本身
select classExtent.getLocation(), classExtent