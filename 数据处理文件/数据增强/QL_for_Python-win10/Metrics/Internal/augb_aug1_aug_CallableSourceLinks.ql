/**
 * @name Python函数源代码位置映射
 * @description 建立Python可调用对象与其源代码文件路径之间的关联
 * @kind source-link
 * @id py/function-source-links
 * @metricType callable
 * 
 * 该查询识别所有Python函数，并将它们与定义它们的源代码文件相关联。
 * 输出结果包括函数对象和对应的源文件路径。
 */

import python

// 获取所有Python函数及其源代码位置信息
from Function pythonFunction
select pythonFunction, pythonFunction.getLocation().getFile()