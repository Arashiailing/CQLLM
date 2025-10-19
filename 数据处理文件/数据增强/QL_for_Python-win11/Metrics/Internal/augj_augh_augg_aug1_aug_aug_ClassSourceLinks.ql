/**
 * @name Python类定义与源文件关联映射
 * @description 分析整个代码库中的Python类定义，建立类与其所在源文件的映射关系。
 *              此查询支持代码结构分析和类定义定位，为代码导航提供基础。
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 检索所有Python类定义及其对应的源文件
from Class pythonClass, File sourceFile
where sourceFile = pythonClass.getLocation().getFile()
// 输出类定义与源文件的映射关系，支持代码导航和结构分析
select pythonClass, sourceFile