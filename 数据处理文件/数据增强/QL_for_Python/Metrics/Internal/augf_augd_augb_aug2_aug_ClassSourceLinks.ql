/**
 * @name Python 类定义源定位
 * @description 识别并定位 Python 项目中所有用户自定义类的定义位置，返回类对象及其源文件的完整路径
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从所有类和源文件中进行查询
from Class userDefinedClass, File sourceFile
// 筛选条件：源文件必须是用户自定义类定义所在的文件
where sourceFile = userDefinedClass.getLocation().getFile()
// 返回结果：类对象及其对应的源文件路径，便于源代码导航和定位
select userDefinedClass, sourceFile