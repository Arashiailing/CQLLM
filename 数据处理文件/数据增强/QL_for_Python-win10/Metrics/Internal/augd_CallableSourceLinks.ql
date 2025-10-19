/**
 * @name 可调用对象的源代码链接
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 选择所有可调用对象及其对应的源文件
from Function callableObj
// 提取可调用对象的源文件位置信息
where exists(callableObj.getLocation())
select callableObj, callableObj.getLocation().getFile()