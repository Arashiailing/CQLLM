/**
 * @name Python函数源代码位置映射
 * @description 映射Python可调用对象到其定义所在的源代码文件路径
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 查询所有Python函数，并获取它们在源代码中的位置信息
from Function callableObj
select callableObj, callableObj.getLocation().getFile()