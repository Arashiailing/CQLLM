/**
 * @name Python函数定义源代码位置追踪
 * @description 建立Python函数定义与其所在源文件路径之间的关联映射
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 获取Python函数定义及其源代码位置
from Function func, Location loc
where loc = func.getLocation()
// 返回函数对象及其源文件路径
select func, loc.getFile()