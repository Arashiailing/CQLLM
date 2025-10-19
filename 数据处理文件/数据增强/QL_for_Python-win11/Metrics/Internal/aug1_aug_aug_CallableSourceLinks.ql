/**
 * @name 可调用实体的源码位置追踪
 * @description 识别Python代码中所有可调用实体（函数定义）并建立与源文件位置的映射关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数定义及其源文件位置
from Function funcDef, Location sourceLocation
where sourceLocation = funcDef.getLocation()
select funcDef, sourceLocation.getFile()