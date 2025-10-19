/**
 * @name 类的源链接
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有 Python 类定义
from Class cls
// 获取类定义的位置信息，并提取其所在文件路径
// 该信息可用于构建源代码链接，便于代码导航和审计
select cls, cls.getLocation().getFile()