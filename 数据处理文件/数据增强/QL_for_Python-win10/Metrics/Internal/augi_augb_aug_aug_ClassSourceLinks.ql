/**
 * @name Python类定义与源文件关联
 * @description 识别所有Python类定义，并建立类与其源定义文件之间的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义Python类及其对应的源文件
from Class pythonClass, File definingFile
where definingFile = pythonClass.getLocation().getFile()
select pythonClass, definingFile