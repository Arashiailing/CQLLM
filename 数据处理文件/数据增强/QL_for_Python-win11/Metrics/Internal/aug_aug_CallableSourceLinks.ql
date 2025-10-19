/**
 * @name 可调用实体的源码位置追踪
 * @description 检测Python代码中所有可调用实体（函数定义）并映射到其源文件位置
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 从函数实体和其代码位置信息中进行选择
from Function functionEntity, Location codeLocation
where codeLocation = functionEntity.getLocation()
select functionEntity, codeLocation.getFile()