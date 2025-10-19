/**
 * @name Extents of callables
 * @kind extent
 * @id py/function-extents
 * @metricType callable
 */

// 导入Python代码分析基础库
import python

// 定义可调用对象范围变量
from Function callable

// 输出可调用对象的位置信息和对象本身
select callable.getLocation(), callable