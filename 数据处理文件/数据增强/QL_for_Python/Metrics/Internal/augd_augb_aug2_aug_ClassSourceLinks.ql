/**
 * @name Python 类定义源定位
 * @description 检测 Python 项目中所有用户自定义类的定义位置，并返回其所在源文件的完整路径
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查询所有用户自定义的类，并获取它们定义所在的源文件
from Class customClass, File definitionFile
where definitionFile = customClass.getLocation().getFile()
// 返回类对象及其对应的源文件路径，用于源代码定位
select customClass, definitionFile