/**
 * @name Python类定义与源文件关联映射
 * @description 分析并映射代码库中所有Python类定义到其所在的源文件位置，建立类与源文件的对应关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义查询目标：Python类定义及其所在的源文件
from Class pythonClass, File classSourceFile
// 筛选条件：源文件必须包含该Python类定义
where classSourceFile = pythonClass.getLocation().getFile()
// 输出结果：Python类定义及其所在的源文件
select pythonClass, classSourceFile