/**
 * @name Python函数源码位置映射
 * @description 该查询通过分析Python代码中的函数定义，建立函数实体与其源码文件位置的映射关系。
 *              这有助于代码审计和源码导航，使开发者能够快速定位函数定义在源文件中的具体位置。
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 从Python代码中提取函数定义及其源文件位置
from Function func, Location loc
where loc = func.getLocation()
select func, loc.getFile()