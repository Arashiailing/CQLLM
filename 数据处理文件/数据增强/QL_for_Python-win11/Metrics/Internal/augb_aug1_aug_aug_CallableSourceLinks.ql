/**
 * @name 可调用实体的源码位置追踪
 * @description 通过分析Python代码中的函数定义，建立可调用实体与其源码文件位置的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 获取所有Python函数定义及其源文件位置
from Function callableEntity, Location funcLocation
where funcLocation = callableEntity.getLocation()
select callableEntity, funcLocation.getFile()