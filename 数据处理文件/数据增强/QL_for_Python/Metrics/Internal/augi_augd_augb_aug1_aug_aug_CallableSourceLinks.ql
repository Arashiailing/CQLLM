/**
 * @name Python函数源码映射
 * @description 检测Python项目中所有函数定义，并提取每个函数所在的源文件路径
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 */

import python

// 从Python函数定义中获取源码文件路径
from Function pythonFunction
select pythonFunction, pythonFunction.getLocation().getFile()