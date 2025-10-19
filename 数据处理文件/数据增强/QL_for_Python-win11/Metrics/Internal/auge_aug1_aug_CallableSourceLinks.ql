/**
 * @name Python函数源代码位置映射
 * @description 映射Python函数定义到其源代码文件的物理位置，用于代码导航和溯源分析
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 定义变量：Python可调用对象和其代码位置
from Function callableObj, Location codeLocation
// 建立函数与源代码位置的关联
where codeLocation = callableObj.getLocation()
// 输出函数对象及其源代码文件路径
select callableObj, codeLocation.getFile()