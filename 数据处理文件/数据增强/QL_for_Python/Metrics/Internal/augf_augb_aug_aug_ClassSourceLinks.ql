/**
 * @name Python类定义与源文件映射
 * @description 识别所有Python类定义，并建立与定义所在源文件路径的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 识别所有Python类定义，并获取其定义所在的源文件
from Class pythonClass, File definingFile
where definingFile = pythonClass.getLocation().getFile()
select pythonClass, definingFile