/**
 * @name 类的源链接
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找所有 Python 类定义
from Class pythonClass
// 获取类定义所在的文件路径，用于源代码链接分析
select pythonClass, pythonClass.getLocation().getFile()