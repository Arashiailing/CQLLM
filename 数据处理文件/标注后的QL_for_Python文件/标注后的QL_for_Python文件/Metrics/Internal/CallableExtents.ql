/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 导入Python库，用于处理Python代码的查询
import python

// 导入Extents库，用于处理范围相关的查询
import Extents

// 从RangeFunction类中选择函数f
from RangeFunction f

// 选择函数f的位置和函数本身
select f.getLocation(), f
