/**
 * @name Python 类定义源定位
 * @description 检测 Python 项目中所有用户自定义类的定义位置，并返回其所在源文件的完整路径
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 获取所有 Python 类定义及其源文件位置
from Class pythonClass, File sourceFile
where sourceFile = pythonClass.getLocation().getFile()
// 输出类对象及其源文件路径
select pythonClass, sourceFile