/**
 * @name Python类的源文件映射
 * @description 该查询用于识别代码库中的所有Python类定义，
 *              并建立每个类与其所在源文件之间的映射关系，
 *              帮助开发者快速定位类定义位置。
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 定义查询范围：从Python代码库中获取所有类定义及其对应的源文件
from Class clsDef, File sourceFile
where 
    // 建立映射关系：获取类定义的位置信息，并提取其所在的源文件
    sourceFile = clsDef.getLocation().getFile()
// 输出结果：类定义对象及其对应的源文件对象，用于建立源链接
select clsDef, sourceFile