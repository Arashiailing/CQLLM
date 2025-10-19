/**
 * @name Python函数定义源码位置映射
 * @description 该查询用于识别Python代码中的函数定义，并建立每个函数与其源代码文件之间的关联关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数定义，并获取它们在源代码中的位置信息
from Function funcDef, Location sourceLocation
where sourceLocation = funcDef.getLocation()
select funcDef, sourceLocation.getFile()