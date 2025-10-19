/**
 * @name 可调用对象的源代码链接
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 检索所有函数对象及其对应的源代码文件位置
from Function callableObj
select callableObj, callableObj.getLocation().getFile()