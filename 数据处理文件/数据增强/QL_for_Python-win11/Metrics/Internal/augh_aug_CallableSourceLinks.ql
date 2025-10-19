/**
 * @name Python函数源代码位置映射
 * @description 识别并提供Python函数与其源代码文件路径之间的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 直接获取每个Python函数及其源文件位置
from Function pythonFunction, Location sourceLocation
where sourceLocation = pythonFunction.getLocation()
select pythonFunction, sourceLocation.getFile()