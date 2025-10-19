/**
 * @name Python 类定义源文件定位
 * @description 检索 Python 代码库中所有类定义，并关联到它们所在的源文件路径
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 获取所有 Python 类定义及其源文件路径
from Class pythonClass, File sourceFile
where sourceFile = pythonClass.getLocation().getFile()
// 选择类对象及其源文件位置
select pythonClass, sourceFile