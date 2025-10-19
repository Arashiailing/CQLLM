/**
 * @name 可调用对象的源代码链接
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数定义并返回函数对象及其源文件位置
// 此查询用于建立函数与其定义文件之间的映射关系，
// 支持代码导航、静态分析和函数定位等场景
from Function func
select func, func.getLocation().getFile()