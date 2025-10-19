/**
 * @name Python 类源代码链接定位
 * @description 识别所有 Python 类定义并获取其源文件位置，用于代码导航和审计
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找项目中的所有 Python 类定义
from Class pythonClass
// 提取类定义的源文件路径，用于构建源代码链接
// 这些链接有助于开发人员快速定位和审查类定义
select pythonClass, pythonClass.getLocation().getFile()