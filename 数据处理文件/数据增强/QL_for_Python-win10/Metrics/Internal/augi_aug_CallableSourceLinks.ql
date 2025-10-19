/**
 * @name 可调用对象的源代码链接
 * @description 提供Python函数与其源文件位置的映射关系，用于代码导航和源代码分析
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 本查询识别所有Python函数，并建立函数与其源文件之间的映射关系
// 这种映射有助于开发者在分析代码时快速定位到函数定义的实际位置
from Function pythonFunction, Location sourceLocation
where sourceLocation = pythonFunction.getLocation()
select pythonFunction, sourceLocation.getFile()