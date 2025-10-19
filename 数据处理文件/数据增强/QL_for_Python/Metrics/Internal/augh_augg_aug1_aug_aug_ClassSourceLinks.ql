/**
 * @name Python类定义与源文件关联分析
 * @description 扫描整个代码库，识别所有Python类定义，并构建类到其源文件的映射。
 *              该查询为代码结构理解和类定义定位提供支持。
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// 遍历所有Python类定义，并确定每个类所在的源文件
from Class cls, File srcFile
where 
    // 验证srcFile是否包含cls的定义
    srcFile = cls.getLocation().getFile()
// 输出类定义及其源文件，支持代码导航和结构分析
select cls, srcFile