/**
 * @name Python类定义与源文件路径映射分析
 * @description 识别并映射代码库中所有Python类定义到它们所在的源文件，建立类与文件之间的关联关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从所有Python类定义中获取类及其所在源文件的映射关系
from Class cls, File srcFile
where srcFile = cls.getLocation().getFile()
// 输出类定义及其对应的源文件信息
select cls, srcFile