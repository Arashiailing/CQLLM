/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 导入Python代码分析基础库，提供代码元素访问能力
import python

// 定义查询范围：所有Python函数对象
from Function func

// 输出每个函数的源代码位置和函数对象本身
select func.getLocation(), func