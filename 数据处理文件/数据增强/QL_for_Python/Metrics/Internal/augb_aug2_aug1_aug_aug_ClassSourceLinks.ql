/**
 * @name Python类定义与源文件路径的关联分析
 * @description 检索代码库中所有Python类定义，并追踪它们所在的源文件路径，建立类与文件间的对应关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 获取所有Python类定义及其对应的源文件
from Class pyClass, File sourceFile
where sourceFile = pyClass.getLocation().getFile()
// 返回类定义及其所在的源文件信息
select pyClass, sourceFile