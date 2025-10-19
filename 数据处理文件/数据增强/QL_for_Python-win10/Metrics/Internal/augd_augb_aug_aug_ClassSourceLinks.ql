/**
 * @name Python类定义与源文件关联
 * @description 识别Python代码中的所有类定义，并建立与这些类定义所在源文件的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 识别所有Python类定义及其所在的源文件
from Class pythonClass, File definingFile
where definingFile = pythonClass.getLocation().getFile()
select pythonClass, definingFile