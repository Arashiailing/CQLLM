/**
 * @name Python 类定义源定位
 * @description 识别 Python 项目中所有用户自定义类的源代码位置，提供类定义与源文件的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义查询变量：用户自定义类和其源文件
from Class userDefinedClass, File classSourceFile
// 获取类定义的位置信息并提取源文件
where classSourceFile = userDefinedClass.getLocation().getFile()
// 返回类对象及其对应的源文件路径
select userDefinedClass, classSourceFile