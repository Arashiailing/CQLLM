/**
 * @name Python 函数定义源码位置映射
 * @description 此查询用于分析 Python 代码库中的所有函数定义，建立每个可调用实体与其源代码文件位置的精确对应关系。
 *              通过这种映射，可以快速定位任何函数定义的源文件，有助于代码审计、依赖分析和安全研究。
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 提取所有 Python 函数定义及其源码位置信息
from Function pyFunction, Location defLocation
where defLocation = pyFunction.getLocation()
select pyFunction, defLocation.getFile()