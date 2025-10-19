/**
 * @name Python函数源代码位置映射
 * @description 建立Python可调用对象与其源代码文件路径之间的关联
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 获取所有Python函数及其源代码位置信息
from Function func, Location sourceLocation
where sourceLocation = func.getLocation()
select func, sourceLocation.getFile()