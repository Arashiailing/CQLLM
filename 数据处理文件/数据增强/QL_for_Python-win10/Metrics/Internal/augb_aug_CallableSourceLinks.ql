/**
 * @name Python函数源文件映射
 * @description 建立Python函数与其源代码文件之间的关联关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 获取所有Python函数及其源文件位置信息
from Function targetFunction, Location sourceLocation
where sourceLocation = targetFunction.getLocation()
select targetFunction, sourceLocation.getFile()