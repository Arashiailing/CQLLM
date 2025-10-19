/**
 * @name 可调用对象的源代码链接
 * @description 提供Python函数与其源文件位置的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 获取所有Python函数及其对应的源文件位置
from Function func, Location sourceLocation
where sourceLocation = func.getLocation()
select func, sourceLocation.getFile()