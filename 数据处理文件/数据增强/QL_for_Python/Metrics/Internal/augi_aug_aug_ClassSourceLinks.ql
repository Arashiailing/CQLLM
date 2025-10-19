/**
 * @name Python类的源文件链接
 * @description 识别所有Python类定义并关联到它们所在的源文件
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有Python类定义
from Class cls
// 提取类定义所在的源文件路径
select cls, cls.getLocation().getFile()