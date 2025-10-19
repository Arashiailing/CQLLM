/**
 * @name Python类的源文件链接
 * @description 查找Python代码中定义的所有类，并确定每个类所在的源文件位置
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有Python类定义
from Class clsDef
// 获取每个类定义的源文件路径
select clsDef, clsDef.getLocation().getFile()