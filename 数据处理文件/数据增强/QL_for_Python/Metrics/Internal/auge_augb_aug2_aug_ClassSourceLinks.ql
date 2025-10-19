/**
 * @name Python 类定义源码定位
 * @description 识别 Python 项目中所有用户自定义类的声明位置，并提供其源文件的完整路径信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 检索所有 Python 类及其对应的源文件
from Class userDefinedClass, File classLocationFile
where 
  // 获取类定义的位置信息，并提取其所在文件
  classLocationFile = userDefinedClass.getLocation().getFile()
// 输出结果：类对象及其源文件路径
select userDefinedClass, classLocationFile