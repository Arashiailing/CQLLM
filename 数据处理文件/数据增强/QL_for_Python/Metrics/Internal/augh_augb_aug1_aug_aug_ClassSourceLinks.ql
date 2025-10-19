/**
 * @name Python类定义与源文件映射分析
 * @description 检测Python代码库中所有类定义元素，并构建类定义与其所在源文件的对应关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 获取Python类定义及其所在源文件的映射关系
from Class pythonClass, File sourceFile
where sourceFile = pythonClass.getLocation().getFile()
// 输出类定义对象及其对应的源文件对象
select pythonClass, sourceFile