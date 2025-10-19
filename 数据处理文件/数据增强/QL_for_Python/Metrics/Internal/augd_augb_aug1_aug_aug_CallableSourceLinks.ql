/**
 * @name 函数源码位置映射
 * @description 识别Python代码中定义的函数，并获取每个函数对应的源文件路径
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 提取所有Python函数定义及其源码位置信息
from Function funcDef, Location sourceLocation
where sourceLocation = funcDef.getLocation()
select funcDef, sourceLocation.getFile()