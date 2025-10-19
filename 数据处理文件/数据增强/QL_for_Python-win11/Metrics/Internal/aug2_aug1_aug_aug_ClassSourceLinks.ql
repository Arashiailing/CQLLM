/**
 * @name Python类与源文件的关联映射
 * @description 识别Python代码中的所有类定义，并建立它们与所在源文件的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 识别所有Python类定义，并获取每个类对应的源文件
from Class cls, File file
where file = cls.getLocation().getFile()
// 输出类定义及其关联的源文件信息
select cls, file