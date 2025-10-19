/**
 * @name Python 类定义源文件定位
 * @description 检索 Python 代码库中所有类定义，并关联到它们所在的源文件路径
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历 Python 代码库中的所有类定义，并确定每个类所在的源文件
// 通过 getLocation() 获取类定义的位置信息，再通过 getFile() 获取源文件对象
from Class definedClass, File containingFile
where containingFile = definedClass.getLocation().getFile()
// 输出类定义对象及其对应的源文件，便于代码导航和依赖分析
select definedClass, containingFile