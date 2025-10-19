/**
 * @name Python类定义与源文件关联分析
 * @description 识别Python代码中的所有类定义，并建立类与其所在源文件之间的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 识别Python代码中的类定义，并确定每个类定义所在的源文件
from Class cls, File file
where file = cls.getLocation().getFile()
// 输出类定义及其对应的源文件信息
select cls, file