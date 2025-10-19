/**
 * @name Python函数源代码位置映射
 * @description 映射Python函数定义到其源代码文件的物理位置，用于代码导航和溯源分析
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 声明变量：Python函数实体及其对应的源码位置信息
from Function pyFunction, Location sourceLocation
// 关联函数定义与其在源代码中的具体位置
where sourceLocation = pyFunction.getLocation()
// 返回函数实体及其所在源文件的路径信息
select pyFunction, sourceLocation.getFile()