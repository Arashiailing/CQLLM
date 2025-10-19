/**
 * @name Python 函数源代码位置链接
 * @description 查询所有 Python 函数对象及其源代码文件位置
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有 Python 函数对象
from Function func
// 返回函数对象及其源代码文件位置
select func, func.getLocation().getFile()