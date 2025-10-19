/**
 * @name Python函数源码位置追踪
 * @description 建立Python函数定义与其源代码文件物理位置的映射关系，支持代码导航和溯源审计
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 获取Python函数定义及其源代码位置信息
from Function pyFunction, Location sourceLocation
// 确保位置信息来源于函数定义本身
where sourceLocation = pyFunction.getLocation()
// 输出函数对象及其所属源代码文件路径
select pyFunction, sourceLocation.getFile()