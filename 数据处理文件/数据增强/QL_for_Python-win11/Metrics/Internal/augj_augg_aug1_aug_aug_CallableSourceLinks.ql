/**
 * @name Python函数源码位置映射
 * @description 检测Python项目中的所有函数定义，并建立函数与其源文件位置的对应关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 检索Python代码中的所有函数定义
// 并建立函数与其源文件位置的映射关系
from Function funcDef, Location srcLocation
where srcLocation = funcDef.getLocation()
select funcDef, srcLocation.getFile()