/**
 * @name Python 类定义源码定位
 * @description 识别 Python 项目中所有用户自定义类的声明位置，并提供其源文件的完整路径信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查询所有用户自定义的 Python 类及其源文件位置
from Class pyClass, File sourceFile
where 
  // 通过类定义的位置信息获取其所在的源文件
  sourceFile = pyClass.getLocation().getFile()
// 输出结果：类对象及其源文件路径
select pyClass, sourceFile