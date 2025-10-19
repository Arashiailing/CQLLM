/**
 * @name Python类的源文件映射
 * @description 识别代码库中的所有Python类定义，并建立类与其所在源文件之间的映射关系。
 *              此查询有助于理解代码结构，快速定位类定义的位置。
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 查找所有Python类定义，并获取每个类所在的源文件
from Class pythonClass, File sourceFile
where 
    // 确保sourceFile是pythonClass所在的文件
    sourceFile = pythonClass.getLocation().getFile()
// 返回类定义及其对应的源文件，以便进行源代码导航和分析
select pythonClass, sourceFile