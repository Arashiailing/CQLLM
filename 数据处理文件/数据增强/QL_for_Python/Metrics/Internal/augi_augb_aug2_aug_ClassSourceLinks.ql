/**
 * @name Python 类定义源定位
 * @description 识别 Python 项目中所有用户自定义类的定义位置，并返回其所在源文件的完整路径
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从所有 Python 类定义中获取类对象及其对应的源文件
from Class userDefinedClass, File classSourceFile
where classSourceFile = userDefinedClass.getLocation().getFile()
// 输出类对象及其源文件路径
select userDefinedClass, classSourceFile