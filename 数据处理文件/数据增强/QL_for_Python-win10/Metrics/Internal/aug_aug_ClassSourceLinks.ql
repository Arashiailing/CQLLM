/**
 * @name Python类的源文件链接
 * @description 识别所有Python类定义并关联到它们所在的源文件
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 识别所有Python类定义，并提取每个类及其对应的源文件路径
from Class pythonClass
// 获取类定义所在的源文件
select pythonClass, pythonClass.getLocation().getFile()