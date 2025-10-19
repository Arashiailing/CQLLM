/**
 * @name 类的源链接
 * @description 查找 Python 代码中所有类的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查询所有 Python 类
from Class pythonClass
// 提取类对象及其源文件路径
select pythonClass, pythonClass.getLocation().getFile()