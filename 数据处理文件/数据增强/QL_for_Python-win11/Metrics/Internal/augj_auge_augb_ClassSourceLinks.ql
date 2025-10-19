/**
 * @name Python类的源代码位置链接
 * @description 提供Python类定义的源代码文件位置，用于生成可点击的源代码链接
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 从所有Python类定义中选择
from Class pythonClass
// 获取类定义的位置信息，并提取其所在文件路径
// 该信息可用于构建源代码链接，便于代码导航和安全审计
select pythonClass, pythonClass.getLocation().getFile()