/**
 * @name Python类的源文件映射
 * @description 查找所有Python类定义，并将其与定义它们的源文件建立关联
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找所有Python类定义，并获取每个类所在的源文件
from Class pyClass, File sourceFile
where sourceFile = pyClass.getLocation().getFile()
// 返回类定义及其对应的源文件
select pyClass, sourceFile