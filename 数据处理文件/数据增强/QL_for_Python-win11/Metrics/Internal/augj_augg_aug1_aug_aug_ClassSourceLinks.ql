/**
 * @name Python类定义源文件定位
 * @description 构建Python类定义与其源文件之间的映射关系。
 *              该查询遍历代码库中的所有类定义，并确定每个类定义所在的源文件，
 *              为代码分析、重构和导航提供基础支持。
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 确定类定义及其源文件位置
from Class classDefinition, File sourceFileLocation
where 
    // 建立类定义与其源文件之间的关联
    sourceFileLocation = classDefinition.getLocation().getFile()
// 输出类定义及其对应的源文件，用于源码导航和分析
select classDefinition, sourceFileLocation