/**
 * @name Extents of classes
 * @kind extent
 * @id py/class-extents
 * @metricType reftype
 */

import python  // 导入Python语言库，用于分析Python代码
import Extents  // 导入Extents模块，用于处理范围和位置信息

// 从RangeClass类中选择元素
from RangeClass c
select c.getLocation(), c  // 选择RangeClass实例的位置和实例本身
