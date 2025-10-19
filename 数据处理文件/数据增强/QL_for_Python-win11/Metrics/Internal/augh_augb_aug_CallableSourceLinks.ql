/**
 * @name Python函数源文件关联映射
 * @description 构建Python函数定义与其所在源代码文件之间的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 检索所有Python函数及其对应的源代码位置信息
from Function pythonFunction, Location codeLocation
where codeLocation = pythonFunction.getLocation()
select pythonFunction, codeLocation.getFile()