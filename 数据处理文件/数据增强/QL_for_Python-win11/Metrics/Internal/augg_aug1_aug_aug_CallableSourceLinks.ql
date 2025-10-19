/**
 * @name 可调用实体的源码位置追踪
 * @description 识别Python代码中所有可调用实体（函数定义）并建立与源文件位置的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 检索Python代码中所有函数定义，并获取其源码位置信息
// 建立函数对象与所在源文件之间的映射关系
from Function callableEntity, Location sourceFileLocation
where sourceFileLocation = callableEntity.getLocation()
select callableEntity, sourceFileLocation.getFile()