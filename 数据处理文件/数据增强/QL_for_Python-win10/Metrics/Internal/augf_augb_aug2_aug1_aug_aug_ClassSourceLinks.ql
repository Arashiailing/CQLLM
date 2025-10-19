/**
 * @name Python类定义与源文件路径映射分析
 * @description 识别代码库中所有Python类定义，并确定它们所在的源文件位置，构建类与文件的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义变量：clsDef表示Python类定义，fileContainer表示包含该类的源文件
from Class clsDef, File fileContainer
// 确保fileContainer是clsDef所在的文件
where fileContainer = clsDef.getLocation().getFile()
// 输出类定义及其所在的源文件信息
select clsDef, fileContainer