/**
 * @name Python可调用对象源码定位
 * @description 构建Python函数与其源代码文件位置之间的关联映射
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 遍历所有Python函数定义，并提取每个函数对应的源文件路径信息
from Function func
where exists(func.getLocation())
select func, func.getLocation().getFile()