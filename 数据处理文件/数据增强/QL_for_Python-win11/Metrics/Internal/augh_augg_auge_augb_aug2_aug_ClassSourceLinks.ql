/**
 * @name Python 类定义源码定位
 * @description 识别 Python 项目中所有用户自定义类的声明位置，并提供其源文件的完整路径信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义查询变量：用户自定义类及其源文件
from Class userDefinedClass, File classSourceFile
where 
  // 获取类定义的位置信息，并从中提取所属源文件
  exists(Location classLocation |
    classLocation = userDefinedClass.getLocation() and
    classSourceFile = classLocation.getFile()
  )
// 输出结果：类对象及其源文件路径
select userDefinedClass, classSourceFile