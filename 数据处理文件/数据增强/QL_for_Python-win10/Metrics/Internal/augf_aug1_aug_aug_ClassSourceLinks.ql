/**
 * @name Python类的源文件映射
 * @description 识别所有Python类定义，并建立类与其源文件之间的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 获取所有Python类及其对应的源文件
from Class pythonClass, File classSourceFile
where classSourceFile = pythonClass.getLocation().getFile()
// 输出类定义及其所在的源文件
select pythonClass, classSourceFile