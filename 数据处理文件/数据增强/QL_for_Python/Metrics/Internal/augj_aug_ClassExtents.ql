/**
 * @name Extents of classes
 * @description Identifies the location and extent of all classes in the codebase.
 * @kind extent
 * @id py/class-extents
 * @metricType reftype
 */

import python

// 遍历代码库中的所有类定义
from Class clsDef
// 输出每个类的位置信息以及类定义本身
select clsDef.getLocation(), clsDef