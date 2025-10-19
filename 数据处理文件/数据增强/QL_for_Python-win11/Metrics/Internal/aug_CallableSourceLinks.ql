/**
 * @name 可调用对象的源代码链接
 * @description 提供Python函数与其源文件位置的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数，并获取每个函数对应的源文件路径
from Function callableObj, Location funcLocation
where funcLocation = callableObj.getLocation()
select callableObj, funcLocation.getFile()