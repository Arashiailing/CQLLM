/**
 * @name Python类定义与源文件关联
 * @description 检测所有Python类定义，并将其与定义所在的源文件路径进行关联
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找所有Python类定义，并获取其所在的源文件
from Class cls, File sourceFile
where sourceFile = cls.getLocation().getFile()
select cls, sourceFile