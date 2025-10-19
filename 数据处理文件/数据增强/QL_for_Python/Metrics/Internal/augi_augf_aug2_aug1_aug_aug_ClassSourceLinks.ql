/**
 * @name Python类与源文件的关联映射
 * @description 识别Python代码中的所有类定义，并建立它们与所在源文件的映射关系
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义变量：classDef表示Python类定义，sourceFile表示源文件
from Class classDef, File sourceFile
// 通过类定义的位置信息获取其所在文件，建立映射关系
where sourceFile = classDef.getLocation().getFile()
// 输出结果：类定义对象及其对应的源文件对象
select classDef, sourceFile