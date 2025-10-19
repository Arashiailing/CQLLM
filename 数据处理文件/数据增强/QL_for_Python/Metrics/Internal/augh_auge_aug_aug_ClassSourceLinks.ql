/**
 * @name Python类的源文件链接
 * @description 识别Python代码中声明的所有类，并追踪每个类的源文件位置信息
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从Python代码中提取所有类定义
from Class classDefinition
// 获取每个类定义的源文件位置
select classDefinition, classDefinition.getLocation().getFile()