/**
 * @name 类的源链接
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有 Python 类定义
from Class cls
// 获取类定义所在源文件路径
select cls, cls.getLocation().getFile()