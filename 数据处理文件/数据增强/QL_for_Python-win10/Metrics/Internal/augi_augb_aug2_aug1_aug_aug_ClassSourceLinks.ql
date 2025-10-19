/**
 * @name Python类定义与源文件路径的关联分析
 * @description 检索代码库中所有Python类定义，并追踪它们所在的源文件路径，建立类与文件间的对应关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义查询范围：所有Python类定义及其所在的源文件
from Class cls, File file
// 建立类与文件的关联关系：通过类的位置信息获取其所在文件
where file = cls.getLocation().getFile()
// 输出结果：类定义及其对应的源文件
select cls, file