/**
 * @name Python函数定义源码映射
 * @description 此查询用于识别Python代码中的所有函数定义，并建立函数实体与其源文件位置之间的映射关系。
 *              通过分析每个函数定义的位置信息，可以快速定位到源代码中的具体实现。
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 从函数定义和其源码位置信息中选择，确保位置信息与函数定义的位置相匹配
from Function funcDef, Location sourceLocation
where sourceLocation = funcDef.getLocation()
select funcDef, sourceLocation.getFile()