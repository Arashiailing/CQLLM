/**
 * @name Python函数源码定位
 * @description 识别并映射Python函数定义与其源代码文件位置，提供代码可追溯性
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 定义变量pyFunction，表示所有Python函数定义
from Function pyFunction

// 筛选条件：确保函数具有有效的源代码位置信息
where exists(pyFunction.getLocation())

// 输出函数对象及其对应的源文件路径
select pyFunction, pyFunction.getLocation().getFile()