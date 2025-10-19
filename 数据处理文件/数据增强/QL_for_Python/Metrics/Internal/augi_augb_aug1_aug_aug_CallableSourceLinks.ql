/**
 * @name Python函数源码位置映射
 * @description 分析Python代码中的函数定义，建立可调用实体与其源文件路径的对应关系
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 提取Python函数定义及其源文件位置信息
from Function pyFunction, Location defLocation
where defLocation = pyFunction.getLocation()
select pyFunction, defLocation.getFile()