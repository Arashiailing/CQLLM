/**
 * @name Python函数源代码位置映射
 * @description 提供Python函数定义与其源代码文件物理位置之间的映射关系，支持代码导航和溯源分析
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数及其源代码位置信息
from Function pythonFunction, Location functionLocation
// 确保位置信息与函数定义相对应
where functionLocation = pythonFunction.getLocation()
// 返回函数对象及其所在的源代码文件路径
select pythonFunction, functionLocation.getFile()