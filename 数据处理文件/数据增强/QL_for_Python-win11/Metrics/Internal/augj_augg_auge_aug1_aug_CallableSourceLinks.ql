/**
 * @name Python函数源代码位置映射
 * @description 建立Python函数定义与其源代码文件物理位置的关联关系，便于代码导航和溯源分析
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 提取Python函数及其对应的源代码位置信息
from Function func, Location funcLoc
where funcLoc = func.getLocation()
// 输出函数对象及其所在的源代码文件路径
select func, funcLoc.getFile()