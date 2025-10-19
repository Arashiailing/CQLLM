/**
 * @name Python类的源文件位置映射
 * @description 识别Python代码库中定义的所有类，并建立类与其源文件之间的关联关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找所有Python类定义及其源文件
from Class pythonClass, File sourceFile
where sourceFile = pythonClass.getLocation().getFile()
select pythonClass, sourceFile