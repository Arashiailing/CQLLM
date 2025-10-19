/**
 * @name Python类的源代码链接
 * @description 识别所有Python类定义并关联其源文件位置，用于源代码链接分析
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历代码库中的所有Python类定义
from Class definedClass
// 提取类定义所在源文件的路径信息，用于生成源代码链接
select definedClass, definedClass.getLocation().getFile()